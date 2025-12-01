#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Tkinter Chess Clock Application

This is the main entrypoint for the native Tkinter-based chess clock application.
It provides:
- Two timers (Player A and Player B)
- Start, Pause, Reset controls
- Simple configuration for initial minutes

Startup logs are printed to stdout to help diagnose startup issues.
"""

import os
import sys
import time
import threading

# Import tkinter defensively to allow clearer error messaging in headless/missing-tk cases
try:
    import tkinter as tk
    from tkinter import ttk, messagebox
    TK_AVAILABLE = True
except Exception as _tk_err:
    tk = None  # type: ignore
    ttk = None  # type: ignore
    messagebox = None  # type: ignore
    TK_AVAILABLE = False

APP_NAME = "Tkinter Chess Clock"
APP_VERSION = "0.1.0"

# PUBLIC_INTERFACE
def log(msg: str) -> None:
    """Simple stdout logger for startup/runtime diagnostics."""
    print(f"[{APP_NAME}] {msg}", flush=True)

class ChessClockApp(tk.Tk):
    """Main application window for the chess clock."""
    def __init__(self) -> None:
        super().__init__()
        self.title(f"{APP_NAME} v{APP_VERSION}")
        self.geometry("420x260")
        self.resizable(False, False)
        self.configure(background="#f9fafb")

        # State
        self.initial_minutes = tk.IntVar(value=5)
        self.seconds_a = tk.IntVar(value=self.initial_minutes.get() * 60)
        self.seconds_b = tk.IntVar(value=self.initial_minutes.get() * 60)
        self.active_player = tk.StringVar(value="A")
        self.running = False
        self._tick_thread = None
        self._stop_event = threading.Event()

        self._build_ui()
        log("UI initialized")

    def _build_ui(self) -> None:
        """Build UI components with a modern look."""
        style = ttk.Style()
        try:
            style.theme_use("clam")
        except tk.TclError:
            pass

        primary = "#2563EB"
        secondary = "#F59E0B"
        surface = "#ffffff"
        text = "#111827"

        container = ttk.Frame(self, padding=14)
        container.pack(fill="both", expand=True)

        # Config row
        config_frame = ttk.LabelFrame(container, text="Configuration", padding=10)
        config_frame.pack(fill="x", pady=(0, 10))
        ttk.Label(config_frame, text="Initial minutes:").grid(row=0, column=0, sticky="w")
        minutes_spin = ttk.Spinbox(config_frame, from_=1, to=180, textvariable=self.initial_minutes, width=6)
        minutes_spin.grid(row=0, column=1, padx=(8, 12))
        apply_btn = ttk.Button(config_frame, text="Apply", command=self._apply_minutes)
        apply_btn.grid(row=0, column=2)

        # Timers
        timers = ttk.Frame(container)
        timers.pack(fill="x", pady=(0, 10))

        self.lbl_a = ttk.Label(timers, text=self._format(self.seconds_a.get()),
                               background=surface, foreground=text, padding=10, anchor="center")
        self.lbl_a.configure(font=("Segoe UI", 20, "bold"))
        self.lbl_a.grid(row=0, column=0, padx=6, sticky="ew")

        self.lbl_b = ttk.Label(timers, text=self._format(self.seconds_b.get()),
                               background=surface, foreground=text, padding=10, anchor="center")
        self.lbl_b.configure(font=("Segoe UI", 20, "bold"))
        self.lbl_b.grid(row=0, column=1, padx=6, sticky="ew")

        timers.grid_columnconfigure(0, weight=1)
        timers.grid_columnconfigure(1, weight=1)

        # Controls
        controls = ttk.Frame(container)
        controls.pack(fill="x")

        self.start_btn = ttk.Button(controls, text="Start", command=self.start)
        self.start_btn.grid(row=0, column=0, padx=4)

        self.pause_btn = ttk.Button(controls, text="Pause", command=self.pause, state="disabled")
        self.pause_btn.grid(row=0, column=1, padx=4)

        self.reset_btn = ttk.Button(controls, text="Reset", command=self.reset)
        self.reset_btn.grid(row=0, column=2, padx=4)

        self.switch_btn = ttk.Button(controls, text="Switch Player", command=self.switch_player, state="disabled")
        self.switch_btn.grid(row=0, column=3, padx=4)

        # Active indicator
        self.active_indicator = ttk.Label(container, text="Active: Player A", foreground=primary)
        self.active_indicator.pack(pady=(10, 0))

        # Keyboard bindings for quick control
        self.bind("<space>", lambda e: self.switch_player() if self.running else None)
        self.bind("<Return>", lambda e: self.start() if not self.running else self.pause())
        self.protocol("WM_DELETE_WINDOW", self.on_close)

        # Accent coloring via styles
        style.configure("TButton", padding=6)
        style.map("TButton",
                  foreground=[("active", text)],
                  background=[("active", secondary)])
        style.configure("Accent.TButton", foreground=surface, background=primary)
        try:
            self.start_btn.configure(style="Accent.TButton")
        except Exception:
            pass

    def _apply_minutes(self) -> None:
        if self.running:
            messagebox.showinfo("Running", "Pause the clock before changing time.")
            return
        mins = max(1, int(self.initial_minutes.get()))
        self.initial_minutes.set(mins)
        self.seconds_a.set(mins * 60)
        self.seconds_b.set(mins * 60)
        self._refresh_labels()
        log(f"Initial minutes set to {mins}")

    def _format(self, total_seconds: int) -> str:
        m, s = divmod(max(0, total_seconds), 60)
        return f"{m:02d}:{s:02d}"

    def _refresh_labels(self) -> None:
        self.lbl_a.configure(text=self._format(self.seconds_a.get()))
        self.lbl_b.configure(text=self._format(self.seconds_b.get()))
        self.active_indicator.configure(text=f"Active: Player {self.active_player.get()}")

    def start(self) -> None:
        if self.running:
            return
        self.running = True
        self._stop_event.clear()
        self.start_btn.configure(state="disabled")
        self.pause_btn.configure(state="normal")
        self.switch_btn.configure(state="normal")
        log("Clock started")
        self._tick_thread = threading.Thread(target=self._tick_loop, daemon=True)
        self._tick_thread.start()

    def pause(self) -> None:
        if not self.running:
            return
        self.running = False
        self._stop_event.set()
        self.start_btn.configure(state="normal")
        self.pause_btn.configure(state="disabled")
        self.switch_btn.configure(state="disabled")
        log("Clock paused")

    def reset(self) -> None:
        if self.running:
            self.pause()
        mins = self.initial_minutes.get()
        self.seconds_a.set(mins * 60)
        self.seconds_b.set(mins * 60)
        self.active_player.set("A")
        self._refresh_labels()
        log("Clock reset")

    def switch_player(self) -> None:
        if not self.running:
            return
        self.active_player.set("B" if self.active_player.get() == "A" else "A")
        self._refresh_labels()
        log(f"Switched active player to {self.active_player.get()}")

    def _tick_loop(self) -> None:
        last = time.time()
        while not self._stop_event.is_set():
            time.sleep(0.05)
            now = time.time()
            elapsed = now - last
            if elapsed >= 1.0:
                last = now
                self._decrement_active()

    def _decrement_active(self) -> None:
        # Update on main thread
        def update():
            if self.active_player.get() == "A":
                self.seconds_a.set(max(0, self.seconds_a.get() - 1))
            else:
                self.seconds_b.set(max(0, self.seconds_b.get() - 1))
            self._refresh_labels()
            if self.seconds_a.get() == 0 or self.seconds_b.get() == 0:
                self.pause()
                messagebox.showinfo("Time", "Time is up!")
                log("Time reached zero")
        self.after(0, update)

    def on_close(self) -> None:
        self.pause()
        self.destroy()

# PUBLIC_INTERFACE
def main() -> int:
    """Entrypoint for launching the Tkinter chess clock app.

    Performs environment diagnostics:
    - Logs Python version and executable
    - Validates tkinter import and logs Tk version if available
    - Detects headless environments (no DISPLAY) and exits gracefully after validation
    """
    log(f"Starting {APP_NAME} v{APP_VERSION}")
    log(f"Python version: {sys.version.split()[0]}")
    log(f"Python executable: {sys.executable}")
    # Environment hints
    log(f"Working directory: {os.getcwd()}")
    log(f"__file__: {__file__}")
    log(f"Absolute path to main.py: {os.path.abspath(__file__)}")

    # Validate tkinter availability and provide clear diagnostics
    if not TK_AVAILABLE:
        log("ERROR: tkinter is not available. Ensure system Tk/Tkinter libraries are installed.")
        # Exit with non-zero code to indicate missing runtime prerequisite
        return 2

    # Print Tk version for clarity
    try:
        log(f"tkinter import OK; TkVersion: {getattr(tk, 'TkVersion', 'unknown')}")
    except Exception:
        pass

    # Headless environment handling: if no DISPLAY, we cannot show GUI
    if os.name != "nt" and not os.environ.get("DISPLAY"):
        log("Headless environment detected (DISPLAY not set). Tkinter validated; exiting gracefully without launching GUI.")
        return 0

    app = ChessClockApp()
    try:
        app.mainloop()
    except Exception as exc:
        log(f"Fatal error: {exc}")
        raise
    finally:
        log("Application closed")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
