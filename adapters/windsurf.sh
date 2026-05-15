#!/usr/bin/env bash
# Adapter: Windsurf
# Appends decision tree to .windsurfrules
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

WINDSURF_FILE="$PROJECT_ROOT/.windsurfrules"

# Extract the body (skip YAML frontmatter)
BODY=$(awk 'BEGIN {skip=1} /^---$/ {if (skip) {skip=0; next} else {skip=2; next}} skip != 2' "$SKILL_FILE")

{
  echo ""
  echo "# ============================================="
  echo "# QMR-web-tool — Web Tool Decision Tree"
  echo "# Added by install.sh on $(date)"
  echo "# ============================================="
  echo ""
  echo "$BODY"
} >> "$WINDSURF_FILE"
