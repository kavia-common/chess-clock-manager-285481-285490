#!/usr/bin/env bash
# NOTE: File must have Unix LF line endings and executable bit set (chmod +x).
# Defensive, verbose launcher for Tkinter Chess Clock native app.
set -euo pipefail

echo "[Tkinter Chess Clock] start.sh: initializing startup sequence"

# Resolve script dir and log absolute paths for diagnostics
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[Tkinter Chess Clock] SCRIPT_DIR: ${SCRIPT_DIR}"
echo "[Tkinter Chess Clock] PWD before cd: $(pwd)"
cd "$SCRIPT_DIR"
echo "[Tkinter Chess Clock] PWD after cd:  $(pwd)"

# Show directory listing to prove presence of start.sh and other files
echo "[Tkinter Chess Clock] Directory listing (ls -la):"
ls -la

# Also print absolute path to this script
echo "[Tkinter Chess Clock] Absolute path to start.sh: ${SCRIPT_DIR}/start.sh"

# Try to ensure the file is executable in case perms were not preserved
chmod +x "${SCRIPT_DIR}/start.sh" || true

# Configurable python and venv directory
PYTHON_BIN="${PYTHON_BIN:-python3}"
VENV_DIR="${VENV_DIR:-.venv}"

echo "[Tkinter Chess Clock] Using python: $PYTHON_BIN"
echo "[Tkinter Chess Clock] Creating/using virtual environment at: $VENV_DIR"

# Create venv if missing
if [ ! -d "$VENV_DIR" ]; then
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

# shellcheck disable=SC1090
source "$VENV_DIR/bin/activate"

echo "[Tkinter Chess Clock] Upgrading pip (best effort)"
python -m pip install --upgrade pip || echo "[Tkinter Chess Clock] pip upgrade failed; continuing"

# Install requirements if present, tolerate missing/deps install failures
if [ -f "requirements.txt" ]; then
  echo "[Tkinter Chess Clock] Installing requirements from requirements.txt"
  if ! pip install -r requirements.txt; then
    echo "[Tkinter Chess Clock] WARNING: pip install failed; continuing (app may still run without optional deps)"
  fi
else
  echo "[Tkinter Chess Clock] requirements.txt not found, skipping pip install"
fi

echo "[Tkinter Chess Clock] Launching application..."
echo "[Tkinter Chess Clock] Working directory: $(pwd)"
echo "[Tkinter Chess Clock] Python: $(python --version 2>&1)"
echo "[Tkinter Chess Clock] Which python: $(command -v python || true)"
echo "[Tkinter Chess Clock] Which pip:    $(command -v pip || true)"

# Run the app
exec python main.py
