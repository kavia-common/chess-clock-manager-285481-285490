#!/usr/bin/env bash
# Robust startup for Tkinter app inside container with headless X (Xvfb).
# - Starts Xvfb if DISPLAY is not already provided
# - Adds traps to ensure child processes are terminated on container stop
# - Uses exec to hand off PID 1 to the Python process for proper signal handling

set -euo pipefail

# Resolve workspace; default to image path where files were copied
WORKSPACE="${WORKSPACE:-/app}"
APP_PY="${APP_PY:-$WORKSPACE/app.py}"

# Ensure we are in workspace
cd "$WORKSPACE"

# Default display if not provided by runtime
export DISPLAY="${DISPLAY:-:99}"

# Function to clean up background processes
cleanup() {
  # Kill Xvfb if we started it
  if [ -n "${XVFB_PID:-}" ] && kill -0 "${XVFB_PID}" 2>/dev/null; then
    kill "${XVFB_PID}" 2>/dev/null || true
    # Give it a moment to exit
    wait "${XVFB_PID}" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

# If DISPLAY looks like :99 or something not already provided, ensure Xvfb is running
# We attempt to start Xvfb unconditionally for the given DISPLAY to simplify logic.
# If an external server is mounted/provided, user can override DISPLAY.
XVFB_BIN="$(command -v Xvfb || true)"
if [ -n "$XVFB_BIN" ]; then
  # Start Xvfb in background, ignore error if already running
  # Use a standard screen size and depth for Tk
  "$XVFB_BIN" "$DISPLAY" -screen 0 1024x768x24 >/dev/null 2>&1 &
  XVFB_PID=$!
  # Brief wait to allow server to initialize
  sleep 0.5
else
  echo "Warning: Xvfb not found in PATH; Tkinter may fail in headless environments." >&2
fi

# Prefer local venv python if available
if [ -x "$WORKSPACE/.venv/bin/python" ]; then
  PYTHON_BIN="$WORKSPACE/.venv/bin/python"
else
  PYTHON_BIN="$(command -v python3)"
fi

# Validate that app exists
if [ ! -f "$APP_PY" ]; then
  echo "Error: Application entrypoint not found at $APP_PY" >&2
  exit 1
fi

# Exec to hand over PID 1 so signals stop the app cleanly (avoids 143 issues)
exec "$PYTHON_BIN" "$APP_PY"
