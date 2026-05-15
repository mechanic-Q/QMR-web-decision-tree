#!/usr/bin/env bash
# ============================================================================
# QMR-web-decision-tree — Universal Installer
# ============================================================================
# Detects AI coding agents installed on the system, installs dependencies,
# and deploys the QMR-web-tool skill to each supported platform.
#
# Usage:
#   chmod +x install.sh && ./install.sh
#   ./install.sh --project /path/to/project   # deploy to project level
#   ./install.sh --global                      # deploy to user level
#   ./install.sh --dry-run                     # show what would be done
# ============================================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FILE="$REPO_DIR/skills/QMR-web-tool/SKILL.md"

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { printf '%b%s%b\n' "${BLUE}" "[INFO]  $*" "${NC}"; }
ok()    { printf '%b%s%b\n' "${GREEN}" "[OK]    $*" "${NC}"; }
warn()  { printf '%b%s%b\n' "${YELLOW}" "[WARN]  $*" "${NC}"; }
fail()  { printf '%b%s%b\n' "${RED}" "[FAIL]  $*" "${NC}"; }

DRY_RUN=false
AGENTS_GENERATED=false
MODE="auto"  # auto | project | global

# Temp file cleanup on exit/interrupt
_INSTALL_TEMP_FILES=()
_cleanup_temps() { rm -f "${_INSTALL_TEMP_FILES[@]}" 2>/dev/null || true; }
trap _cleanup_temps EXIT INT TERM

# ------------------------------------------------------------------
# Parse args
# ------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --project) MODE="project"; PROJECT_DIR="${2:?--project requires a path argument}"; shift 2 ;;
    --global)  MODE="global"; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ------------------------------------------------------------------
# Step 0: Preflight
# ------------------------------------------------------------------
echo ""
echo "=============================================="
echo " QMR-web-decision-tree — Universal Installer"
echo "=============================================="
echo ""

if [ ! -f "$SKILL_FILE" ]; then
  fail "SKILL.md not found at $SKILL_FILE"
  exit 1
fi

# Determine project root
if [ "$MODE" = "global" ]; then
  PROJECT_ROOT="$HOME"
elif [ "$MODE" = "project" ]; then
  PROJECT_ROOT="$PROJECT_DIR"
else
  PROJECT_ROOT="$(pwd)"
fi

ok "Repository: $REPO_DIR"
ok "Target:      $PROJECT_ROOT"

# ------------------------------------------------------------------
# Step 1: Detect installed AI coding agents
# ------------------------------------------------------------------
_detect_agents() {
  local agents=()
  if [ -d "$HOME/.claude" ]; then agents+=("claude-code"); fi
  if [ -d "$HOME/.config/opencode" ] || [ -d "$HOME/.opencode" ]; then agents+=("opencode"); fi
  if [ -d "$HOME/.codex" ] || [ -d "$HOME/.agents/skills" ]; then agents+=("codex"); fi
  if [ -d "$HOME/.openclaw" ]; then agents+=("openclaw"); fi
  if [ -d "$PROJECT_ROOT/.cursor" ]; then agents+=("cursor"); fi
  if [ -d "$PROJECT_ROOT/.clinerules" ] || [ -d "$HOME/Documents/Cline/Rules" ]; then agents+=("cline"); fi
  if [ -f "$PROJECT_ROOT/.windsurfrules" ]; then agents+=("windsurf"); fi
  if [ -f "$PROJECT_ROOT/.aider.conf.yml" ]; then agents+=("aider"); fi
  echo ${agents[@]+"${agents[@]}"}
}

echo ""
echo "--- Step 1: Detecting AI Coding Agents ---"
AGENTS=($(_detect_agents))
for a in "${AGENTS[@]+"${AGENTS[@]}"}"; do info "Detected: $a"; done

if [ ${#AGENTS[@]} -eq 0 ]; then
  warn "No AI coding agents detected. Will install skill globally."
  warn "Supported agents: Claude Code, OpenCode, Codex, OpenClaw, Cursor, Cline, Windsurf, Aider"
  # Still install globally, but skip agent-specific adapters
fi

# ------------------------------------------------------------------
# Step 2: Install Python & Node dependencies
# ------------------------------------------------------------------
install_deps() {
  echo ""
  echo "--- Step 2: Installing Dependencies ---"

  # Python packages
  info "Installing Python dependencies..."
  if command -v pip3 &>/dev/null; then
    if $DRY_RUN; then
      info "[DRY-RUN] pip3 install -r \"$REPO_DIR/requirements.txt\" --break-system-packages"
    else
      PIP_LOG=$(mktemp) && _INSTALL_TEMP_FILES+=("$PIP_LOG")
      if pip3 install -r "$REPO_DIR/requirements.txt" --break-system-packages > "$PIP_LOG" 2>&1; then
        tail -3 "$PIP_LOG"
        ok "Python dependencies installed"
      else
        fail "pip install failed:"
        cat "$PIP_LOG"
        rm "$PIP_LOG"
        return 1
      fi
      rm "$PIP_LOG"
    fi
  elif command -v pip &>/dev/null; then
    if $DRY_RUN; then
      info "[DRY-RUN] pip install -r \"$REPO_DIR/requirements.txt\" --break-system-packages"
    else
      PIP_LOG=$(mktemp) && _INSTALL_TEMP_FILES+=("$PIP_LOG")
      if pip install -r "$REPO_DIR/requirements.txt" --break-system-packages > "$PIP_LOG" 2>&1; then
        tail -3 "$PIP_LOG"
        ok "Python dependencies installed"
      else
        fail "pip install failed:"
        cat "$PIP_LOG"
        rm "$PIP_LOG"
        return 1
      fi
      rm "$PIP_LOG"
    fi
  else
    fail "pip not found. Install Python 3 first."
    return 1
  fi

  # Playwright browsers (idempotent — skips already installed)
  if $DRY_RUN; then
    info "[DRY-RUN] playwright install chromium"
  else
    info "Installing Playwright browsers..."
    if python3 -m playwright install chromium 2>&1 | tail -3; then
      ok "Playwright browsers installed"
    else
      warn "Playwright install incomplete (run: python3 -m playwright install chromium)"
    fi
  fi

  # Camoufox browser binary (always attempts fetch; cache detection inside)
  if $DRY_RUN; then
    info "[DRY-RUN] python3 -m camoufox fetch"
  else
    info "Checking camoufox browser binary..."
    (python3 -m camoufox fetch 2>&1 || true) | tail -3
    if python3 -c "import camoufox; camoufox.get_path('camoufox')" 2>/dev/null; then
      ok "Camoufox browser binary ready"
    else
      warn "Camoufox browser binary not cached — run: python3 -m camoufox fetch"
    fi
  fi

  # Node.js packages
  if command -v npm &>/dev/null; then
    if [ -d "$PROJECT_ROOT/node_modules/camofox-browser" ]; then
      ok "camofox-browser already installed in project"
      else
        info "Installing camofox-browser..."
        if $DRY_RUN; then
          info "[DRY-RUN] npm install --save-dev camofox-browser"
        else
          if (cd "$PROJECT_ROOT" && npm install --save-dev camofox-browser) 2>&1 | tail -3; then
            ok "camofox-browser installed"
          else
            warn "npm install failed — install manually: npm install --save-dev camofox-browser"
          fi
        fi
    fi
  else
    warn "npm not found. Install Node.js to use camofox-browser."
  fi
}

install_deps

# ------------------------------------------------------------------
# Step 3: Deploy skill to each detected agent
# ------------------------------------------------------------------
deploy_skill() {
  echo ""
  echo "--- Step 3: Deploying Skill to Agents ---"

  local ADAPTERS_DIR="$REPO_DIR/adapters"

  for agent in "${AGENTS[@]+"${AGENTS[@]}"}"; do
    local adapter="$ADAPTERS_DIR/$agent.sh"
    if [ -f "$adapter" ]; then
      info "Deploying to $agent..."
      if $DRY_RUN; then
        info "[DRY-RUN] bash \"$adapter\" \"$SKILL_FILE\" \"$PROJECT_ROOT\""
      else
        bash "$adapter" "$SKILL_FILE" "$PROJECT_ROOT" && ok "$agent: deployed" || warn "$agent: deployment skipped"
      fi
    else
      warn "No adapter found for $agent (expected: $adapter)"
    fi
  done
}

deploy_skill

# ------------------------------------------------------------------
# Step 4: Generate AGENTS.md (cross-platform bridge)
# ------------------------------------------------------------------
generate_agents_md() {
  echo ""
  echo "--- Step 4: Generating AGENTS.md ---"

  local AGENTS_MD="$PROJECT_ROOT/AGENTS.md"
  if [ -f "$AGENTS_MD" ]; then
    warn "AGENTS.md already exists at $AGENTS_MD — not overwriting"
    return
  fi

  if $DRY_RUN; then
    info "[DRY-RUN] Would create $AGENTS_MD"
    return
  fi

  cat > "$AGENTS_MD" << 'AGENTS'
# QMR-web-tool — Intelligent Web Tool Decision Tree

This project provides an intelligent decision tree for AI coding agents
to automatically select the best web scraping/search/anti-detection tool
based on the task at hand.

## How It Works

When you need to access web content, the decision tree routes you through
the optimal tool chain:

1. **Search** → ddgs / multi-search-engine / arxiv / blogwatcher
2. **Simple fetch** → webfetch → crawl4ai → scrapling Fetcher
3. **JavaScript rendering** → scrapling DynamicFetcher
4. **Anti-detection needed** → httpcloak → camoufox → fallbacks

## Tool Downgrade Chain

camoufox > httpcloak > StealthyFetcher > Fetcher(impersonate)
> DynamicFetcher > Fetcher > crawl4ai > webfetch
> Archive.org > search engine cache

## Quick Reference

| Tool | Best For |
|------|----------|
| ddgs | DuckDuckGo text/news/image/video search |
| webfetch | Simple page fetch (built-in, zero install) |
| crawl4ai | LLM-optimized output, full site crawl |
| scrapling Fetcher | HTTP fetch with TLS fingerprinting |
| scrapling DynamicFetcher | JS-rendered pages (SPA) |
| scrapling StealthyFetcher | Cloudflare Turnstile bypass |
| httpcloak | HTTP/2+3, JA3/JA4 perfect TLS simulation |
| camoufox | Anti-detection browser (C++ fingerprint spoofing) |
| camofox-browser | Multi-agent shared browser (REST API) |
| agent-browser-cli | Interactive browser automation |

For the full decision tree, see the skill file installed in your
agent's skill directory.
AGENTS

  ok "AGENTS.md created at $AGENTS_MD"
  AGENTS_GENERATED=true
}

generate_agents_md

# ------------------------------------------------------------------
# Step 5: Verify installation
# ------------------------------------------------------------------
verify() {
  echo ""
  echo "--- Step 5: Verification ---"

  if $DRY_RUN; then
    info "[DRY-RUN] Would run check.sh"
    return
  fi

  bash "$REPO_DIR/check.sh" 2>&1 || true
}

verify

# ------------------------------------------------------------------
# Report
# ------------------------------------------------------------------
echo ""
echo "=============================================="
echo " Installation Complete"
echo "=============================================="
echo ""

if [ ${#AGENTS[@]} -gt 0 ]; then
  ok "Adapted for: ${AGENTS[*]}"
else
  warn "No agents auto-detected. Skill file available at:"
  info "  $SKILL_FILE"
  info "Copy it to your agent's skill directory manually."
fi

if $AGENTS_GENERATED; then
  ok "AGENTS.md generated for cross-platform compatibility"
fi
info "Run ./check.sh anytime to verify tool availability"
info ""
info "If you encounter issues with Chinese network, use mirror:"
info "  pip install -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt --break-system-packages"
