#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="${WORKSPACE:-/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app}"
cd "$WORKSPACE"
export DISPLAY="${DISPLAY:-:99}"
if [ -x "$WORKSPACE/.venv/bin/python" ]; then
  exec "$WORKSPACE/.venv/bin/python" "$WORKSPACE/app.py"
else
  exec python3 "$WORKSPACE/app.py"
fi
