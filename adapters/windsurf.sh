#!/usr/bin/env bash
# Adapter: Windsurf
# Appends decision tree to .windsurfrules
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

WINDSURF_FILE="$PROJECT_ROOT/.windsurfrules"

# Extract body after YAML frontmatter (everything after second '---')
BODY=$(awk '/^---$/ {c++; next} c >= 2' "$SKILL_FILE")

{
  echo ""
  echo "# ============================================="
  echo "# QMR-web-tool — Web Tool Decision Tree"
  echo "# Added by install.sh on $(date)"
  echo "# ============================================="
  echo ""
  echo "$BODY"
} >> "$WINDSURF_FILE"
