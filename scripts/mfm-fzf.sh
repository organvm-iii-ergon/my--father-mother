#!/usr/bin/env bash
# Interactive fzf palette using recent/semantic/fts; copies selected clip to clipboard.
# Usage:
#   ./scripts/mfm-fzf.sh                  # recent
#   ./scripts/mfm-fzf.sh --query "auth"   # FTS search
#   ./scripts/mfm-fzf.sh --semantic "auth token"  # semantic search

set -euo pipefail

if ! command -v fzf >/dev/null 2>&1; then
  echo "fzf is required (brew install fzf)"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUERY=""
SEMANTIC=0
LIMIT=200

if [[ $# -gt 0 ]]; then
  if [[ "$1" == "--semantic" ]]; then
    SEMANTIC=1
    QUERY="$2"
  elif [[ "$1" == "--query" ]]; then
    QUERY="$2"
  fi
fi

cd "$REPO_DIR"

json=""
if [[ -n "$QUERY" ]]; then
  if [[ $SEMANTIC -eq 1 ]]; then
    json="$(python3 main.py semantic-search "$QUERY" --limit $LIMIT --pool $((LIMIT*5)) | python3 - <<'PY'
import sys, re
import json
lines = sys.stdin.read().strip().splitlines()
out = []
pat = re.compile(r'#\s*(\d+)\s+.*?\[(.*?)\]\s+(.*)')
for line in lines:
    m = pat.search(line)
    if not m: continue
    cid = int(m.group(1))
    app = m.group(2)
    content = m.group(3)
    out.append({"id": cid, "source_app": app, "content": content})
print(json.dumps(out))
PY)"
  else
    json="$(python3 main.py search "$QUERY" --limit $LIMIT | python3 - <<'PY'
import sys, re, json
lines = sys.stdin.read().strip().splitlines()
out = []
pat = re.compile(r'#\s*(\d+)\s+.*?\[(.*?)\]\s+(.*)')
for line in lines:
    m = pat.search(line)
    if not m: continue
    cid = int(m.group(1))
    app = m.group(2)
    content = m.group(3)
    out.append({"id": cid, "source_app": app, "content": content})
print(json.dumps(out))
PY)"
  fi
else
  json="$(python3 main.py export --limit $LIMIT)"
fi

echo "$json" | python3 - <<'PY' | fzf --ansi --no-sort --with-nth=1.. -1 | cut -d':' -f1 | xargs -I{} python3 main.py copy --id {} >/dev/null && echo "[father] copied"
import sys, json
try:
    data = json.load(sys.stdin)
except Exception as e:
    sys.exit(0)
for item in data:
    cid = item.get("id")
    app = item.get("source_app", "unknown")
    title = (item.get("title") or "")[:60]
    content = (item.get("content") or "").replace("\n"," \\n")
    if len(content) > 80:
        content = content[:77] + "..."
    print(f"{cid}:{app:<15} {title} | {content}")
PY
