#!/usr/bin/env bash
# Rofi-based palette for my--father-mother.
# Usage:
#   ./scripts/mfm-rofi.sh                 # recent list
#   ./scripts/mfm-rofi.sh --query "auth"  # FTS search
#   ./scripts/mfm-rofi.sh --semantic "auth token"  # semantic search

set -euo pipefail

if ! command -v rofi >/dev/null 2>&1; then
  echo "rofi is required (e.g., brew install rofi)"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUERY=""
SEMANTIC=0
LIMIT=200

while [[ $# -gt 0 ]]; do
  case "$1" in
    --query)
      QUERY="${2:-}"
      shift 2
      ;;
    --semantic)
      SEMANTIC=1
      QUERY="${2:-}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-200}"
      shift 2
      ;;
    *)
      echo "unknown arg: $1"
      exit 1
      ;;
  esac
done

cd "$REPO_DIR"

json=""
if [[ -n "$QUERY" ]]; then
  if [[ $SEMANTIC -eq 1 ]]; then
    json="$(python3 main.py semantic-search "$QUERY" --limit "$LIMIT" --pool $((LIMIT*5)) | python3 - <<'PY'
import sys, re, json
lines = sys.stdin.read().strip().splitlines()
out = []
pat = re.compile(r'#\s*(\d+)\s+.*?\[(.*?)\]\s+(.*)')
for line in lines:
    m = pat.search(line)
    if not m:
        continue
    cid = int(m.group(1))
    app = m.group(2)
    content = m.group(3)
    out.append({"id": cid, "source_app": app, "content": content})
print(json.dumps(out))
PY)"
  else
    json="$(python3 main.py search "$QUERY" --limit "$LIMIT" | python3 - <<'PY'
import sys, re, json
lines = sys.stdin.read().strip().splitlines()
out = []
pat = re.compile(r'#\s*(\d+)\s+.*?\[(.*?)\]\s+(.*)')
for line in lines:
    m = pat.search(line)
    if not m:
        continue
    cid = int(m.group(1))
    app = m.group(2)
    content = m.group(3)
    out.append({"id": cid, "source_app": app, "content": content})
print(json.dumps(out))
PY)"
  fi
else
  json="$(python3 main.py export --limit "$LIMIT")"
fi

choice="$(echo "$json" | python3 - <<'PY' | rofi -dmenu -i -p "father" || true
import sys, json
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for item in data:
    cid = item.get("id")
    app = item.get("source_app", "unknown")
    title = (item.get("title") or "")[:60]
    content = (item.get("content") or "").replace("\n"," \\n")
    if len(content) > 80:
        content = content[:77] + "..."
    print(f"{cid}:{app:<15} {title} | {content}")
PY)"

if [[ -z "${choice:-}" ]]; then
  exit 0
fi

clip_id="${choice%%:*}"

if python3 main.py copy --id "$clip_id" >/dev/null; then
  echo "[father] copied clip #$clip_id"
else
  echo "[father] failed to copy"
fi
