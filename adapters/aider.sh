#!/usr/bin/env bash
# Adapter: Aider
# Adds SKILL.md path to .aider.conf.yml read list
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

AIDER_CONF="$PROJECT_ROOT/.aider.conf.yml"
DEST="$PROJECT_ROOT/.aider-QMR-web-tool.md"

awk 'BEGIN {skip=1} /^---$/ {if (skip) {skip=0; next} else {skip=2; next}} skip != 2' "$SKILL_FILE" > "$DEST"

# Merge into .aider.conf.yml read list using Python (safe YAML merge)
if [ -f "$AIDER_CONF" ]; then
  python3 -c "
import yaml, os
conf_file = '$AIDER_CONF'
dest = '$DEST'
with open(conf_file) as f:
    conf = yaml.safe_load(f) or {}
reads = conf.get('read', [])
if isinstance(reads, str):
    reads = [reads]
if dest not in reads:
    reads.append(dest)
    conf['read'] = reads
    with open(conf_file, 'w') as f:
        yaml.dump(conf, f, default_flow_style=False)
    print(f'Added {dest} to {conf_file}')
" 2>/dev/null || {
  # Fallback: append if Python/yaml not available
  if ! grep -q "aider-QMR-web-tool" "$AIDER_CONF" 2>/dev/null; then
    echo "" >> "$AIDER_CONF"
    echo "# Added by QMR-web-decision-tree" >> "$AIDER_CONF"
    echo "read: [$DEST]" >> "$AIDER_CONF"
  fi
}
fi
