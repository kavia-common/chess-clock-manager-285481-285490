#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="${WORKSPACE:-/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app}"
# Install minimal packages if missing (idempotent)
sudo apt-get update -qq && sudo apt-get install -yq --no-install-recommends python3-venv python3-tk x11-utils >/dev/null 2>&1 || true
# Ensure /etc/profile.d sets DISPLAY only if unset at login shells (non-intrusive)
PROFILE=/etc/profile.d/ci_display.sh
if [ ! -f "$PROFILE" ]; then
  sudo bash -c 'cat > /etc/profile.d/ci_display.sh <<EOF
# set DISPLAY to :99 only if not set
if [ -z "${DISPLAY:-}" ]; then
  export DISPLAY=":99"
fi
EOF'
  sudo chmod 644 /etc/profile.d/ci_display.sh
fi
# verify essential tools
command -v python3 >/dev/null || { echo "python3 missing" >&2; exit 2; }
command -v pytest >/dev/null || true
