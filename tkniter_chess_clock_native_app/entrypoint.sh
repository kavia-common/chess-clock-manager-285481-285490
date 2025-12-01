#!/usr/bin/env bash
# Alias entrypoint for environments expecting 'entrypoint.sh'.
# Ensure LF endings and executable bit are set (chmod +x).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${SCRIPT_DIR}/start.sh"

echo "[Tkinter Chess Clock] entrypoint.sh delegating to ${TARGET}"
if [ ! -f "$TARGET" ]; then
  echo "[Tkinter Chess Clock] ERROR: start.sh not found at ${TARGET}"
  exit 127
fi

chmod +x "$TARGET" || true
exec "$TARGET"
