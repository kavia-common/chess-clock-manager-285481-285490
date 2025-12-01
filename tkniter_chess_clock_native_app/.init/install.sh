#!/usr/bin/env bash
set -euo pipefail
# Idempotently create workspace-local venv and install pytest only
WORKSPACE="/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app"
cd "$WORKSPACE"
# diagnostic: ensure python3 and system pip callable
if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 not found" >&2
  exit 10
fi
if ! python3 -m pip --version >/tmp/python3-pip-check.log 2>&1; then
  echo "warning: system pip check failed, see /tmp/python3-pip-check.log" >&2
fi
# create venv idempotently
if [ ! -d "$WORKSPACE/.venv" ]; then
  python3 -m venv "$WORKSPACE/.venv"
fi
VENV_PY="$WORKSPACE/.venv/bin/python"
if [ ! -x "$VENV_PY" ]; then
  echo "error: venv python not found at $VENV_PY" >&2
  exit 11
fi
# upgrade packaging tools and capture logs for diagnostics
/tmp/venv-pip-upgrade.log && rm -f /tmp/venv-pip-upgrade.log || true
"$VENV_PY" -m pip install --upgrade pip setuptools wheel >/tmp/venv-pip-upgrade.log 2>&1 || { echo "venv pip upgrade failed, see /tmp/venv-pip-upgrade.log" >&2; exit 3; }
# install pytest only and capture logs
/tmp/venv-pip-install.log && rm -f /tmp/venv-pip-install.log || true
"$VENV_PY" -m pip install pytest >/tmp/venv-pip-install.log 2>&1 || { echo "pip install pytest failed, see /tmp/venv-pip-install.log" >&2; exit 4; }
# surface installed pytest version for reproducibility
"$VENV_PY" - <<'PY'
import sys
try:
    import pytest
    print('pytest', pytest.__version__)
except Exception as e:
    print('pytest import failed:', e, file=sys.stderr)
    sys.exit(5)
PY
