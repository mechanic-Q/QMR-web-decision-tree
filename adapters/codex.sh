#!/usr/bin/env bash
# Adapter: Codex
# Deploys SKILL.md → .agents/skills/QMR-web-tool/SKILL.md (project + global)
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

mkdir -p "$PROJECT_ROOT/.agents/skills/QMR-web-tool"
cp "$SKILL_FILE" "$PROJECT_ROOT/.agents/skills/QMR-web-tool/SKILL.md"

mkdir -p "$HOME/.agents/skills/QMR-web-tool"
cp "$SKILL_FILE" "$HOME/.agents/skills/QMR-web-tool/SKILL.md"
