Minimal scaffold for tkniter_chess_clock_native_app.

Usage
-----
- Launch the GUI: ./start.sh (it prefers ./.venv/bin/python if present)
- Default DISPLAY is :99 when not set; override with environment variable: DISPLAY=:0 ./start.sh

Validation & Logs
-----------------
- A separate validation step writes logs to ./validation-logs/ and performs ephemeral checks.
- Run validation with: ./validation (or ./validation --keep-alive to leave the GUI running for manual VNC inspection)

Behavior
--------
- The Tk GUI opens a window and runs root.mainloop() indefinitely to allow manual VNC inspection.
- The scaffold uses the authoritative workspace path but allows override via WORKSPACE env var.
