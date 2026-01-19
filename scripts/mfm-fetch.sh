#!/usr/bin/env bash
# Fetch a clip (latest, by id, or by query) and print to stdout; optional copy.
# Example: ./scripts/mfm-fetch.sh --latest
#          ./scripts/mfm-fetch.sh --id 12 --copy
#          ./scripts/mfm-fetch.sh --query "auth token" --semantic --copy

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
QUERY=""
SEMANTIC=0
ID=""
COPY=0
APP=""
TAG=""

usage() {
  echo "Usage: $0 [--latest] [--id N] [--query Q] [--semantic] [--app APP] [--tag TAG] [--copy]"
  exit 1
}

if [[ $# -eq 0 ]]; then
  # default to latest
  :
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --latest) QUERY=""; ID="";;
    --id) ID="$2"; shift;;
    --query) QUERY="$2"; shift;;
    --semantic) SEMANTIC=1;;
    --app) APP="$2"; shift;;
    --tag) TAG="$2"; shift;;
    --copy) COPY=1;;
    -h|--help) usage;;
    *) usage;;
  esac
  shift
done

cd "$REPO_DIR"

fetch_clip() {
  local cid="$1"
  python3 - <<'PY'
import json, sys, subprocess
cid = sys.argv[1]
proc = subprocess.run(["python3", "main.py", "show", "--id", cid], capture_output=True, text=True)
if proc.returncode != 0:
    sys.exit(proc.returncode)
print(proc.stdout.strip().split("\n", maxsplit=1)[-1])
PY
}

out=""

if [[ -n "$ID" ]]; then
  out="$(python3 main.py show --id "$ID" | sed '1d')"
elif [[ -n "$QUERY" ]]; then
  if [[ $SEMANTIC -eq 1 ]]; then
    out="$(python3 main.py semantic-search "$QUERY" --limit 1 --app "$APP" --tag "$TAG" | sed -n '1p' | sed 's/^.*] //')"
  else
    out="$(python3 main.py search "$QUERY" --limit 1 --app "$APP" --tag "$TAG" | sed -n '1p' | sed 's/^.*] //')"
  fi
else
  out="$(python3 main.py recent --limit 1 | sed -n '1p' | sed 's/^.*] //')"
fi

echo -n "$out"

if [[ $COPY -eq 1 ]]; then
  printf "%s" "$out" | pbcopy
fi
