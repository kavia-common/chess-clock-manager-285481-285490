#!/usr/bin/env bash
set -euo pipefail

echo "[Tkinter Chess Clock] start.sh: initializing startup sequence"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${VENV_DIR:-.venv}"

echo "[Tkinter Chess Clock] Using python: $PYTHON_BIN"
echo "[Tkinter Chess Clock] Creating/using virtual environment at: $VENV_DIR"

if [ ! -d "$VENV_DIR" ]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

# Ensure script is executable when run in environments that do not preserve mode
# This is a no-op if permissions are already correct.
chmod +x "$SCRIPT_DIR/start.sh" || true

# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

echo "[Tkinter Chess Clock] Upgrading pip"
python -m pip install --upgrade pip

if [ -f "requirements.txt" ]; then
  echo "[Tkinter Chess Clock] Installing requirements from requirements.txt"
  pip install -r requirements.txt
else
  echo "[Tkinter Chess Clock] requirements.txt not found, skipping pip install"
fi

echo "[Tkinter Chess Clock] Launching application..."
echo "[Tkinter Chess Clock] Working directory: $(pwd)"
echo "[Tkinter Chess Clock] Python: $(python --version 2>&1)"

# Run the app
exec python main.py
