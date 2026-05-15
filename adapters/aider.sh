#!/usr/bin/env bash
# Adapter: Aider
# Adds SKILL.md path to .aider.conf.yml read list
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

AIDER_CONF="$PROJECT_ROOT/.aider.conf.yml"
DEST="$PROJECT_ROOT/.aider-QMR-web-tool.md"

# Copy skill as a conventions file (strip frontmatter for cleaner output)
awk 'BEGIN {skip=1} /^---$/ {if (skip) {skip=0; next} else {skip=2; next}} skip != 2' "$SKILL_FILE" > "$DEST"

# Add to .aider.conf.yml if it exists
if [ -f "$AIDER_CONF" ]; then
  if grep -q "aider-QMR-web-tool" "$AIDER_CONF" 2>/dev/null; then
    : # already present
  else
    echo "read: [$DEST]" >> "$AIDER_CONF"
  fi
fi
