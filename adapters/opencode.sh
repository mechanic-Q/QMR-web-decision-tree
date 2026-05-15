#!/usr/bin/env bash
# Adapter: OpenCode
# Deploys SKILL.md → .opencode/skills/QMR-web-tool/SKILL.md (project + global)
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

mkdir -p "$PROJECT_ROOT/.opencode/skills/QMR-web-tool"
cp "$SKILL_FILE" "$PROJECT_ROOT/.opencode/skills/QMR-web-tool/SKILL.md"

mkdir -p "$HOME/.config/opencode/skills/QMR-web-tool"
cp "$SKILL_FILE" "$HOME/.config/opencode/skills/QMR-web-tool/SKILL.md"
