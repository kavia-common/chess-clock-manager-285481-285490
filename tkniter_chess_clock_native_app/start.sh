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
# Activate venv if it exists; if activation fails, continue with system python
if [ -f "$VENV_DIR/bin/activate" ]; then
  # shellcheck disable=SC1091
  source "$VENV_DIR/bin/activate" || echo "[Tkinter Chess Clock] WARNING: could not activate venv; proceeding with system python"
else
  echo "[Tkinter Chess Clock] WARNING: venv activation script not found; proceeding with system python"
fi

echo "[Tkinter Chess Clock] Python executable: $(python - <<'PY'
import sys, sysconfig
print(sys.executable)
print(sys.version)
print(sysconfig.get_platform())
PY
)"

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

# Detect OS package manager
detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then echo "apt"; return 0; fi
  if command -v apk >/dev/null 2>&1; then echo "apk"; return 0; fi
  if command -v dnf >/dev/null 2>&1; then echo "dnf"; return 0; fi
  if command -v yum >/dev/null 2>&1; then echo "yum"; return 0; fi
  if command -v zypper >/dev/null 2>&1; then echo "zypper"; return 0; fi
  echo "unknown"
}

# Try to import tkinter and print Tk version
echo "[Tkinter Chess Clock] Verifying tkinter availability..."
if python - <<'PY'
try:
    import tkinter as tk
    import sys
    print("tkinter OK; TkVersion:", tk.TkVersion)
    sys.exit(0)
except Exception as e:
    print("tkinter import failed:", repr(e))
    sys.exit(1)
PY
then
  TK_OK=1
else
  TK_OK=0
fi

# If tkinter import failed, try to install system packages
if [ "$TK_OK" -eq 0 ]; then
  PKG_MGR="$(detect_pkg_mgr)"
  echo "[Tkinter Chess Clock] Attempting to install Tk/Tkinter via package manager: ${PKG_MGR}"
  case "$PKG_MGR" in
    apt)
      sudo_cmd=""
      if command -v sudo >/dev/null 2>&1; then sudo_cmd="sudo"; fi
      $sudo_cmd apt-get update -y || true
      # Install tk and python3-tk for Debian/Ubuntu
      $sudo_cmd apt-get install -y tk python3-tk || true
      ;;
    apk)
      # Alpine
      apk add --no-cache tcl tk || true
      # python3-tkinter may not exist on all Alpine variants; try and ignore failures
      apk add --no-cache python3-tkinter || true
      ;;
    dnf)
      dnf install -y tk python3-tkinter || true
      ;;
    yum)
      yum install -y tk python3-tkinter || true
      ;;
    zypper)
      zypper --non-interactive refresh || true
      zypper --non-interactive install tk python3-tk || true
      ;;
    *)
      echo "[Tkinter Chess Clock] Unknown package manager; please ensure Tk/Tkinter are installed on the base image."
      ;;
  esac

  echo "[Tkinter Chess Clock] Re-checking tkinter after install attempt..."
  if python - <<'PY'
try:
    import tkinter as tk
    import sys
    print("tkinter OK after install; TkVersion:", tk.TkVersion)
    sys.exit(0)
except Exception as e:
    print("tkinter still failing:", repr(e))
    sys.exit(1)
PY
  then
    echo "[Tkinter Chess Clock] tkinter import successful after installation."
  else
    echo "[Tkinter Chess Clock] ERROR: tkinter is unavailable; GUI may not run. Proceeding to attempt headless-safe start."
  fi
fi

# Headless environment check note (app will also check and exit gracefully)
if [ -z "${DISPLAY:-}" ]; then
  echo "[Tkinter Chess Clock] NOTICE: DISPLAY not set; running in headless environment. The application will validate tkinter import and exit gracefully if GUI cannot be displayed."
fi

echo "[Tkinter Chess Clock] Launching application..."
echo "[Tkinter Chess Clock] Working directory: $(pwd)"
echo "[Tkinter Chess Clock] Python: $(python --version 2>&1)"
echo "[Tkinter Chess Clock] Which python: $(command -v python || true)"
echo "[Tkinter Chess Clock] Which pip:    $(command -v pip || true)"

# Run the app
exec python main.py
