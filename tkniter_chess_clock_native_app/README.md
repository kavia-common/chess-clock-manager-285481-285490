# Tkinter Chess Clock - Native App

This container hosts a native Tkinter application for a chess clock.

## How it's started

- `start.sh` is the entrypoint used by the preview system.
- It creates a Python virtual environment (`.venv`), installs `requirements.txt`, and runs `python main.py`.

## Manual run

```bash
cd chess-clock-manager-285481-285490/tkniter_chess_clock_native_app
# Ensure executable permissions (in case your environment stripped them)
chmod +x start.sh run.sh entrypoint.sh
# Preferred
bash start.sh
# Fallbacks
bash run.sh
bash entrypoint.sh
```

### Notes
- Ensure files use Unix LF line endings.
- The launcher prints an ls -la listing and absolute path to start.sh at startup to verify correct path resolution.
- Tkinter auto-detection and installation:
  - On startup, `start.sh` validates `import tkinter` and, if missing, attempts to install system packages based on the base image:
    - Debian/Ubuntu: `apt-get install -y tk python3-tk`
    - Alpine: `apk add --no-cache tcl tk python3-tkinter` (python3-tkinter may not exist on all variants)
    - Fedora/RHEL: `dnf/yum install -y tk python3-tkinter`
    - openSUSE: `zypper install tk python3-tk`
  - After installation, it retries the import and logs success or failure.
- Headless environments:
  - If `DISPLAY` is not set (typical in CI), the app validates Tkinter import and then exits gracefully without attempting to create a GUI window.
  - This ensures CI runs pass without a display server while still verifying dependencies.

You'll see logs like:

```
[Tkinter Chess Clock] start.sh: initializing startup sequence
[Tkinter Chess Clock] Using python: python3
[Tkinter Chess Clock] Creating/using virtual environment at: .venv
...
[Tkinter Chess Clock] Launching application...
[Tkinter Chess Clock] Working directory: ...
[Tkinter Chess Clock] Python: 3.x.y
[Tkinter Chess Clock] Starting Tkinter Chess Clock v0.1.0
[Tkinter Chess Clock] UI initialized
```

If run in an environment without a display server, Tkinter may fail to open. This is expected in headless CI; the startup logs are sufficient to verify the script path correctness.

## Dependencies

- Tkinter (bundled with standard Python builds)  
- Pillow (optional, installed via `requirements.txt`)

## Environment variables

- `PYTHON_BIN` (optional): path to Python interpreter (default `python3`)
- `VENV_DIR` (optional): venv directory (default `.venv`)
