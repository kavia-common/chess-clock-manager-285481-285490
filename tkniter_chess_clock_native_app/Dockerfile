# syntax=docker/dockerfile:1

# Base image with Python 3
FROM python:3.11-slim

# Avoid interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system packages needed for Tkinter and headless X (Xvfb)
# Keep footprint minimal and clean apt lists
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

# Delegate startup to start.sh (which handles Xvfb and Python execution)
# Use explicit /bin/bash path to avoid PATH resolution issues in minimal images.
ENTRYPOINT ["/bin/bash", "/app/start.sh"]
