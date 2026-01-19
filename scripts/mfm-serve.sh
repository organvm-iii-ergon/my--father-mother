#!/usr/bin/env bash
# Serve API/UI with sensible defaults, restarting on exit if KeepAlive (used by LaunchAgent).

set -euo pipefail
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PORT="${PORT:-8765}"

cd "$REPO_DIR"
exec python3 main.py serve --port "$PORT"
