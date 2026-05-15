#!/usr/bin/env bash
# Adapter: Cline
# Deploys SKILL.md → .clinerules/qmr-web-tool.md (project) + ~/Documents/Cline/Rules/ (global)
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

# Project level
mkdir -p "$PROJECT_ROOT/.clinerules"
cp "$SKILL_FILE" "$PROJECT_ROOT/.clinerules/qmr-web-tool.md"

# Global level (Linux)
mkdir -p "$HOME/Documents/Cline/Rules"
cp "$SKILL_FILE" "$HOME/Documents/Cline/Rules/qmr-web-tool.md"
