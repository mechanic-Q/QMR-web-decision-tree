#!/usr/bin/env bash
# ============================================================================
# QMR-web-decision-tree — Dependency Health Check
# ============================================================================
# Validates that all web tools are installed and working.
# Run anytime to verify installation integrity.
#
# Usage:
#   ./check.sh
#   ./check.sh --verbose   # detailed per-tool info
# ============================================================================
set -euo pipefail

VERBOSE=false
[[ "${1:-}" == "--verbose" ]] && VERBOSE=true

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; }

echo ""
echo "=============================================="
echo " QMR-web-tool — Health Check"
echo "=============================================="
echo ""

PYTHON_TOOLS=(
  "scrapling:from scrapling.fetchers import Fetcher"
  "stealthy:from scrapling.fetchers import StealthyFetcher"
  "camoufox:from camoufox.sync_api import Camoufox"
  "httpcloak:import httpcloak"
  "crawl4ai:import crawl4ai"
  "ddgs:import ddgs"
  "playwright:from playwright.sync_api import sync_playwright"
)

COLUMNS=62

# Python tools
info "Python libraries:"
for entry in "${PYTHON_TOOLS[@]}"; do
  name="${entry%%:*}"
  imp="${entry#*:}"
  if python3 -c "$imp" 2>/dev/null; then
    ok "  $(printf '%-20s' "$name") installed"
    $VERBOSE && python3 -c "
$imp
import inspect, importlib
# Find the actual top-level module from the import statement
for name in ['scrapling', 'camoufox', 'httpcloak', 'crawl4ai', 'ddgs', 'playwright']:
    try:
        m = importlib.import_module(name)
        v = getattr(m, '__version__', None)
        if v:
            print(f'    {name} version: {v}')
            break
    except Exception:
        continue
" 2>/dev/null || true
  else
    fail "  $(printf '%-20s' "$name") MISSING — pip install it"
  fi
done

echo ""

# CLI tools
info "CLI tools:"
for cmd in ddgs go node npm python3; do
  if command -v "$cmd" &>/dev/null; then
    ver=$("$cmd" --version 2>&1 | head -1)
    ok "  $(printf '%-20s' "$cmd") $ver"
  else
    fail "  $(printf '%-20s' "$cmd") not found in PATH"
  fi
done

echo ""

# Special checks
info "Special checks:"

# Camoufox browser binary
if python3 -c "import camoufox; camoufox.get_path('camoufox')" 2>/dev/null; then
  ok "  camoufox browser binary  found"
else
  warn "  camoufox browser binary  not cached — run: python -m camoufox fetch"
fi

# Playwright browser
if python3 -c "import playwright; print(playwright.__file__)" &>/dev/null; then
  if python3 -c "from playwright.sync_api import sync_playwright" 2>/dev/null; then
    ok "  playwright browsers       available (or will auto-download)"
  else
    warn "  playwright                needs: python3 -m playwright install chromium"
  fi
else
  warn "  playwright                MISSING"
fi

# camofox-browser Node.js
for p in "node_modules/camofox-browser/bin/camofox-browser.js" \
         "../node_modules/camofox-browser/bin/camofox-browser.js" \
         "$HOME/node_modules/camofox-browser/bin/camofox-browser.js"; do
  if [ -f "$p" ]; then
    ok "  camofox-browser           found at $p"
    break
  fi
done
CB_JS=$(find . -name 'camofox-browser.js' 2>/dev/null | head -1 || true)
if [ ! -f "${CB_JS:-}" ] && [ ! -f "$HOME/node_modules/camofox-browser/bin/camofox-browser.js" ]; then
  warn "  camofox-browser           not installed — npm install --save-dev camofox-browser"
fi

# httpcloak version + preset availability
if python3 -c "import httpcloak" 2>/dev/null; then
  hc_ver=$(python3 -c "import httpcloak; print(httpcloak.__version__)" 2>/dev/null || echo "unknown")
  hc_presets=$(python3 -c "import httpcloak; print(len(httpcloak.available_presets()))" 2>/dev/null || echo "unknown")
  ok "  httpcloak v$hc_ver        $hc_presets presets available"
fi

echo ""
echo "=============================================="
echo " Health Check Complete"
echo "=============================================="
echo ""
info "For full tool details:  ./check.sh --verbose"
info "To reinstall:           ./install.sh"
