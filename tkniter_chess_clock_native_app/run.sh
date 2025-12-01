#!/usr/bin/env bash
# Fallback launcher that delegates to start.sh in the same directory.
# Ensure LF endings and executable bit are set (chmod +x).
set -euo pipefail

echo "[Tkinter Chess Clock] run.sh: starting fallback launcher"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[Tkinter Chess Clock] run.sh SCRIPT_DIR: ${SCRIPT_DIR}"
echo "[Tkinter Chess Clock] run.sh PWD: $(pwd)"

TARGET="${SCRIPT_DIR}/start.sh"
if [ ! -f "$TARGET" ]; then
  echo "[Tkinter Chess Clock] ERROR: start.sh not found at ${TARGET}"
  echo "[Tkinter Chess Clock] Directory listing of SCRIPT_DIR:"
  ls -la "${SCRIPT_DIR}" || true
  exit 127
fi

chmod +x "$TARGET" || true
echo "[Tkinter Chess Clock] run.sh invoking ${TARGET}"
exec "$TARGET"
