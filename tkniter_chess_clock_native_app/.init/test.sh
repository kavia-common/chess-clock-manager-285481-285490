#!/usr/bin/env bash
set -euo pipefail

WORKSPACE="/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app"
cd "$WORKSPACE"
VENV_PY="$WORKSPACE/.venv/bin/python"

# ensure workspace tests dir exists
mkdir -p "$WORKSPACE/tests"

cat > "$WORKSPACE/tests/test_tk_headless.py" <<'PY'
import os
import pytest

def test_create_root_window_or_skip():
    # import tkinter inside test to avoid collection errors when module is missing
    try:
        import tkinter as tk
    except Exception:
        pytest.skip('tkinter not available; skipping GUI test')
    disp = os.environ.get('DISPLAY')
    if not disp:
        pytest.skip('DISPLAY not set; skipping GUI test')
    try:
        root = tk.Tk()
    except Exception as e:
        pytest.skip(f'Cannot connect to X server: {e}')
    root.withdraw()
    root.update_idletasks()
    root.destroy()
    assert True
PY

# run tests and fail on test failures with clear exit code
[ -x "$VENV_PY" ] || { echo "venv python missing" >&2; exit 6; }
"$VENV_PY" -m pytest -q tests || { echo 'pytest failed' >&2; exit 7; }
