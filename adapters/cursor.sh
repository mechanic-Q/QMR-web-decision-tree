#!/usr/bin/env bash
# Adapter: Cursor
# Converts SKILL.md → .cursor/rules/qmr-web-tool.mdc (with frontmatter)
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

CURSOR_RULES="$PROJECT_ROOT/.cursor/rules"
mkdir -p "$CURSOR_RULES"

MDC_FILE="$CURSOR_RULES/qmr-web-tool.mdc"

# Extract body after YAML frontmatter (everything after second '---')
BODY=$(awk '/^---$/ {c++; next} c >= 2' "$SKILL_FILE")

{
  cat << 'MDCHEADER'
---
description: "scrape|scraping|crawl|search|research|investigate|web-search|anti-bot|cloudflare-bypass|fetch|spider"
globs: ["*"]
alwaysApply: true
---

MDCHEADER
  printf '%s' "$BODY"
} > "$MDC_FILE"
