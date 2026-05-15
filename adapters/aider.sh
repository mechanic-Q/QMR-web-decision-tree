#!/usr/bin/env bash
# Adapter: Aider
# Adds SKILL.md path to .aider.conf.yml read list
set -euo pipefail

SKILL_FILE="$1"
PROJECT_ROOT="$2"

AIDER_CONF="$PROJECT_ROOT/.aider.conf.yml"
DEST="$PROJECT_ROOT/.aider-QMR-web-tool.md"

# Extract body after YAML frontmatter
awk '/^---$/ {c++; next} c >= 2' "$SKILL_FILE" > "$DEST"

# Merge into .aider.conf.yml read list
if [ -f "$AIDER_CONF" ]; then
  python3 - "$AIDER_CONF" "$DEST" << 'PYEOF'
import sys, yaml, os

conf_file = sys.argv[1]
dest = sys.argv[2]

with open(conf_file) as f:
    conf = yaml.safe_load(f) or {}

reads = conf.get('read') or []
if isinstance(reads, str):
    reads = [reads]

if dest not in reads:
    reads.append(dest)
    conf['read'] = reads
    with open(conf_file, 'w') as f:
        yaml.dump(conf, f, default_flow_style=False)
    print(f'Added {dest} to {conf_file}')
PYEOF
fi
