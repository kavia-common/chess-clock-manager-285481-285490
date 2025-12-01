# syntax=docker/dockerfile:1

# Base image with Python 3
FROM python:3.11-slim

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system packages needed for Tkinter and headless X (Xvfb)
# - python3-tk/tk provide Tk libraries
# - xvfb enables headless X display at :99
# - xauth, x11-apps are useful for validation and X utilities (small footprint)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3-tk \
        tk \
        xvfb \
        xauth \
        x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy application files
COPY app.py /app/app.py
COPY start.sh /app/start.sh
COPY README.md /app/README.md

# Make sure start.sh is executable
RUN chmod +x /app/start.sh

# Default display used by start.sh if not provided
ENV DISPLAY=:99

# Optional: create a venv if you plan to add Python deps later (kept minimal here)
# You can uncomment and add pip installs if/when dependencies are introduced.
# RUN python -m venv /app/.venv && . /app/.venv/bin/activate && pip install --no-cache-dir -U pip

# Start an X virtual framebuffer to support Tkinter in headless environments, then run the app.
# Using a small wrapper command here to ensure Xvfb is up before starting the app.
# Note: start.sh prefers ./.venv/bin/python if present, else uses system python3.
ENTRYPOINT ["/bin/bash", "-lc", "Xvfb :99 -screen 0 1024x768x24 & exec /app/start.sh"]
