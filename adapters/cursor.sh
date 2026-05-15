#!/usr/bin/env bash
# Adapter: Cursor
# Converts SKILL.md → .cursor/rules/qmr-web-tool.mdc (with frontmatter)
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

CURSOR_RULES="$PROJECT_ROOT/.cursor/rules"
mkdir -p "$CURSOR_RULES"

MDC_FILE="$CURSOR_RULES/qmr-web-tool.mdc"

# Extract the body (skip YAML frontmatter)
BODY=$(awk 'BEGIN {skip=1} /^---$/ {if (skip) {skip=0; next} else {skip=2; next}} skip != 2' "$SKILL_FILE")

cat > "$MDC_FILE" << CURSOR
---
description: "scrape|scraping|crawl|search|research|investigate|web-search|anti-bot|cloudflare-bypass|fetch|spider"
globs: ["*"]
alwaysApply: true
---

$BODY
CURSOR
