#!/usr/bin/env bash
# ============================================================================
# QMR-web-decision-tree — Installation Validation Tests
# ============================================================================
# Validates that the install script correctly deploys to all platforms.
#
# Usage:
#   bash tests/test_install.sh                          # run all tests
#   bash tests/test_install.sh --ci                     # exit 1 on first failure
# ============================================================================
set -euo pipefail

CI_MODE=false
[[ "${1:-}" == "--ci" ]] && CI_MODE=true

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()  { printf '%b%s%b\n' "${BLUE}" "[INFO]  $*" "${NC}"; }
ok()    { printf '%b%s%b\n' "${GREEN}" "[PASS]  $*" "${NC}"; }
fail()  { printf '%b%s%b\n' "${RED}" "[FAIL]  $*" "${NC}"; $CI_MODE && exit 1 || true; }

TESTS_RUN=0
TESTS_PASS=0

assert_file() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$1" ]; then
        ok "File exists: $1"
        TESTS_PASS=$((TESTS_PASS + 1))
    else
        fail "File missing: $1"
    fi
}

assert_file_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    if [ -f "$1" ] && grep -q "$2" "$1" 2>/dev/null; then
        ok "File '$1' contains '$2'"
        TESTS_PASS=$((TESTS_PASS + 1))
    else
        fail "File '$1' does not contain '$2'"
    fi
}

echo ""
echo "=============================================="
echo " QMR-web-decision-tree — Installation Tests"
echo "=============================================="
echo ""

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

info "Temp test directory: $TEMP_DIR"

# ------------------------------------------------------------------
# Test 1: Repository structure
# ------------------------------------------------------------------
echo ""
info "Test Suite 1: Repository Structure"

assert_file "$REPO_DIR/skills/QMR-web-tool/SKILL.md"
assert_file "$REPO_DIR/install.sh"
assert_file "$REPO_DIR/check.sh"
assert_file "$REPO_DIR/requirements.txt"
assert_file "$REPO_DIR/LICENSE"

for adapter in claude-code opencode codex openclaw cursor cline windsurf aider; do
    assert_file "$REPO_DIR/adapters/$adapter.sh"
done

for example in simple_scrape.py js_render.py cloudflare_bypass.py search_news.sh interactive.sh; do
    assert_file "$REPO_DIR/examples/$example"
done

assert_file "$REPO_DIR/tests/test_install.sh"

# ------------------------------------------------------------------
# Test 2: SKILL.md has valid YAML frontmatter
# ------------------------------------------------------------------
echo ""
info "Test Suite 2: SKILL.md Validity"

assert_file_contains "$REPO_DIR/skills/QMR-web-tool/SKILL.md" "name: QMR-web-tool"
assert_file_contains "$REPO_DIR/skills/QMR-web-tool/SKILL.md" "description:"
assert_file_contains "$REPO_DIR/skills/QMR-web-tool/SKILL.md" "camoufox"
assert_file_contains "$REPO_DIR/skills/QMR-web-tool/SKILL.md" "httpcloak"
assert_file_contains "$REPO_DIR/skills/QMR-web-tool/SKILL.md" "scrapling"

# No hardcoded paths
if grep -q '/mnt/e/' "$REPO_DIR/skills/QMR-web-tool/SKILL.md"; then
    fail "SKILL.md contains hardcoded /mnt/e/ paths"
else
    ok "No hardcoded paths in SKILL.md"
    TESTS_PASS=$((TESTS_PASS + 1))
fi
TESTS_RUN=$((TESTS_RUN + 1))

# ------------------------------------------------------------------
# Test 3: install.sh dry-run
# ------------------------------------------------------------------
echo ""
info "Test Suite 3: Installer Dry Run"

output=$(bash "$REPO_DIR/install.sh" --dry-run 2>&1) || true
if echo "$output" | grep -q "DRY-RUN"; then
    ok "install.sh --dry-run produces DRY-RUN output"
    TESTS_PASS=$((TESTS_PASS + 1))
else
    fail "install.sh --dry-run failed"
fi
TESTS_RUN=$((TESTS_RUN + 1))

# ------------------------------------------------------------------
# Test 4: Adapter scripts are valid
# ------------------------------------------------------------------
echo ""
info "Test Suite 4: Adapter Script Syntax"

for adapter in "$REPO_DIR"/adapters/*.sh; do
    name=$(basename "$adapter")
    if bash -n "$adapter"; then
        ok "Syntax OK: $name"
        TESTS_PASS=$((TESTS_PASS + 1))
    else
        fail "Syntax error in $name"
    fi
    TESTS_RUN=$((TESTS_RUN + 1))
done

# ------------------------------------------------------------------
# Test 5: check.sh is valid
# ------------------------------------------------------------------
echo ""
info "Test Suite 5: check.sh Syntax"

if bash -n "$REPO_DIR/check.sh"; then
    ok "check.sh syntax OK"
    TESTS_PASS=$((TESTS_PASS + 1))
else
    fail "check.sh syntax error"
fi
TESTS_RUN=$((TESTS_RUN + 1))

# ------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------
echo ""
echo "=============================================="
echo " Test Results"
echo "=============================================="
echo ""
ok "$TESTS_PASS / $TESTS_RUN tests passed"

if [ "$TESTS_PASS" -eq "$TESTS_RUN" ]; then
    printf '%b%s%b\n' "${GREEN}" "All tests passed!" "${NC}"
else
    printf '%b%s%b\n' "${RED}" "$((TESTS_RUN - TESTS_PASS)) tests FAILED" "${NC}"
    exit 1
fi
