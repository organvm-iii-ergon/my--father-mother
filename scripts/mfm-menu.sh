#!/usr/bin/env bash
# Menu launcher for my--father-mother: choose Moon watcher, Father shell, Serve, Palette, Recent, Recap.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

menu() {
  cat <<'EOF'
1) Start Moon watcher (clipboard)
2) Father shell
3) Serve web UI/API
4) Palette (interactive picker)
5) Recent (CLI)
6) Recap (last 60m)
7) List tags
8) Latest (copy to clipboard)
9) Quit
EOF
}

run_choice() {
  case "$1" in
    1) (cd "$REPO_DIR" && python3 main.py watch --cap 5000) ;;
    2) (cd "$REPO_DIR" && exec "${SHELL:-/bin/zsh}") ;;
    3) (cd "$REPO_DIR" && python3 main.py serve --port 8765) ;;
    4) (cd "$REPO_DIR" && python3 main.py palette --limit 30) ;;
    5) (cd "$REPO_DIR" && python3 main.py recent --limit 20) ;;
    6) (cd "$REPO_DIR" && python3 main.py recap --minutes 60 --limit 200) ;;
    7) (cd "$REPO_DIR" && python3 main.py tags --list-all) ;;
    8) (cd "$REPO_DIR" && ./scripts/mfm-fetch.sh --latest --copy) ;;
    *) exit 0 ;;
  esac
}

while true; do
  menu
  read -r -p "Select: " choice
  run_choice "$choice"
done
