#!/usr/bin/env bash
# Dual-pane tmux session: left = Mother (watcher), right = Father (interactive shell).
# Requires tmux installed.

set -euo pipefail

SESSION="mfm"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors (ANSI): Mother (moon) = teal, Father (sun) = gold
MOTHER_C="\033[38;5;37m"
FATHER_C="\033[38;5;214m"
RESET="\033[0m"

WATCH_CMD="cd \"$REPO_DIR\" && printf \"${MOTHER_C}[mother|moon] ever-watching; capturing clipboard${RESET}\n\" && python3 main.py watch --cap 5000"

# Father prompt: warm, direct
FATHER_PROMPT='[father|sun] radiant shell$ '
FATHER_CMD="cd \"$REPO_DIR\" && clear; printf \"${FATHER_C}[father|sun] awake; ask me for recent/search/export${RESET}\n\"; export PS1=\"${FATHER_C}${FATHER_PROMPT}${RESET}\"; exec ${SHELL:-/bin/zsh}"

if ! command -v tmux >/dev/null 2>&1; then
  echo "tmux is required. Install via: brew install tmux"
  exit 1
fi

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new-session -d -s "$SESSION" "$WATCH_CMD"
  tmux split-window -h -t "$SESSION" "$FATHER_CMD"
tmux select-pane -t "$SESSION":0.0
fi

tmux attach -t "$SESSION"
