#!/usr/bin/env bash
# Adapter: Claude Code
# Deploys SKILL.md → .claude/skills/QMR-web-tool/SKILL.md (project + global)
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

mkdir -p "$PROJECT_ROOT/.claude/skills/QMR-web-tool"
cp "$SKILL_FILE" "$PROJECT_ROOT/.claude/skills/QMR-web-tool/SKILL.md"

# Also install globally
mkdir -p "$HOME/.claude/skills/QMR-web-tool"
cp "$SKILL_FILE" "$HOME/.claude/skills/QMR-web-tool/SKILL.md"
