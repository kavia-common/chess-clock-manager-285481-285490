#!/usr/bin/env bash
set -euo pipefail
# scaffold workspace and minimal Tk app, run and venv helpers
WORKSPACE="/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app"
mkdir -p "$WORKSPACE" && cd "$WORKSPACE"
# app.py: minimal Tk app with WM_DELETE_WINDOW and signal handlers
cat > "$WORKSPACE/app.py" <<'PY'
import logging
import sys
import tkinter as tk
import signal

logging.basicConfig(stream=sys.stdout, level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s', force=True)
logger = logging.getLogger('tkniter')
logger.info('Tk app initializing')

root = tk.Tk()
root.title('tkniter-demo')
label = tk.Label(root, text='Chess Clock Manager - Demo')
label.pack(padx=20, pady=20)

# graceful window close handler
def _on_close():
    try:
        root.destroy()
    except Exception:
        pass

root.protocol('WM_DELETE_WINDOW', _on_close)

# signal handlers to ensure clean shutdown when receiving TERM/INT
def _term_handler(signum, frame):
    try:
        # quit the Tk mainloop; destroy from main thread when it exits
        root.quit()
    except Exception:
        pass

signal.signal(signal.SIGTERM, _term_handler)
signal.signal(signal.SIGINT, _term_handler)

logger.info('Tk app started')
# ensure immediate flush
sys.stdout.flush()
root.mainloop()
PY

# run.sh: prefers workspace-local venv python and computes workspace at runtime
cat > "$WORKSPACE/run.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DISPLAY=${DISPLAY:-:99}
if [ -x "$WORKSPACE/.venv/bin/python" ]; then
  exec "$WORKSPACE/.venv/bin/python" -u "$WORKSPACE/app.py"
else
  exec /usr/bin/env python3 -u "$WORKSPACE/app.py"
fi
SH
chmod +x "$WORKSPACE/run.sh"

# activate-venv.sh: helper to source local venv
cat > "$WORKSPACE/activate-venv.sh" <<'ACT'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$WORKSPACE/.venv/bin/activate" ]; then
  . "$WORKSPACE/.venv/bin/activate"
else
  echo "venv not found at $WORKSPACE/.venv" >&2; return 2
fi
ACT
chmod +x "$WORKSPACE/activate-venv.sh"

# README
cat > "$WORKSPACE/README.md" <<'MD'
Minimal Tk app scaffold for headless CI. Use ./run.sh to start the app. Activate the venv with ./activate-venv.sh when present.
MD

# ensure ownership and permissions are reasonable (non-destructive)
chmod 644 "$WORKSPACE/README.md" || true
chmod 755 "$WORKSPACE/app.py" || true

# report success
echo "scaffold: created files in $WORKSPACE"
