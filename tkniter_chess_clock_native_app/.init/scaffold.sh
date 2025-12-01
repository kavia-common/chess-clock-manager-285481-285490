#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="${WORKSPACE:-/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app}"
mkdir -p "$WORKSPACE"
# app.py: minimal tkinter app that opens a window
cat > "$WORKSPACE/app.py" <<'PY'
#!/usr/bin/env python3
import sys
try:
    import tkinter as tk
except Exception as e:
    print('tkinter import failed:', e, file=sys.stderr); raise
root = tk.Tk()
root.title('Validation GUI')
lbl = tk.Label(root, text='Test GUI - close to exit')
lbl.pack(padx=20, pady=20)
# keep window open
root.mainloop()
PY
chmod +x "$WORKSPACE/app.py"
# start.sh: prefer .venv python if available
cat > "$WORKSPACE/start.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="${WORKSPACE:-/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app}"
if [ -x "$WORKSPACE/.venv/bin/python" ]; then
  exec "$WORKSPACE/.venv/bin/python" "$WORKSPACE/app.py"
else
  exec python3 "$WORKSPACE/app.py"
fi
SH
chmod +x "$WORKSPACE/start.sh"
# README explaining logs and keep-alive behavior
cat > "$WORKSPACE/README.validation.md" <<'MD'
Validation logs: validation-logs/ contains app stdout/stderr, process.info, snapshot or xdpyinfo, and validation.status
Run validation ephemeral: ./.init/validation.sh
To keep the app running for manual VNC inspection pass --keep-alive
MD
