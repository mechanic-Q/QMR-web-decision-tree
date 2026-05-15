#!/usr/bin/env bash
# Adapter: OpenClaw
# Deploys SKILL.md → ~/.openclaw/workspace/skills/QMR-web-tool/SKILL.md
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

OPENCLAW_SKILLS="$HOME/.openclaw/workspace/skills/QMR-web-tool"
mkdir -p "$OPENCLAW_SKILLS"
cp "$SKILL_FILE" "$OPENCLAW_SKILLS/SKILL.md"
