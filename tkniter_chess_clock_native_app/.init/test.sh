#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="${WORKSPACE:-/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app}"
cd "$WORKSPACE"
# create a simple pytest to verify tkinter can open a root window
mkdir -p "$WORKSPACE/tests"
cat > "$WORKSPACE/tests/test_tk.py" <<'PY'
import tkinter as tk

def test_tk_create_and_destroy():
    root = tk.Tk()
    root.withdraw()
    root.update()
    root.destroy()
    assert True
PY
# ensure DISPLAY is set
: "${DISPLAY:=:99}"
# quick probe to ensure Tk can open display
"$WORKSPACE/.venv/bin/python" - <<'PY'
import tkinter as tk
root=tk.Tk(); root.withdraw(); root.update(); root.destroy(); print('tk-ok')
PY
# run pytest
"$WORKSPACE/.venv/bin/pytest" -q "$WORKSPACE/tests" || true
