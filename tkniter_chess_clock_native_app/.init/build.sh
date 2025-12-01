#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="${WORKSPACE:-/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app}"
cd "$WORKSPACE"
# create venv if missing
if [ ! -d "$WORKSPACE/.venv" ]; then
  python3 -m venv "$WORKSPACE/.venv"
fi
# upgrade pip/setuptools in venv non-interactively
"$WORKSPACE/.venv/bin/python" -m pip install --upgrade pip setuptools >/dev/null 2>&1 || true
# install pytest into venv for tests
"$WORKSPACE/.venv/bin/python" -m pip install pytest >/dev/null 2>&1 || true
