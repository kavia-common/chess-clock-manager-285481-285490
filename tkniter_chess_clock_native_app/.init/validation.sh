#!/usr/bin/env bash
set -euo pipefail
# validation - start app, verify logs, and stop cleanly
WORKSPACE="/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app"
cd "$WORKSPACE"
export DISPLAY=${DISPLAY:-:99}
LOG="$WORKSPACE/validation.log"
rm -f "$LOG" "$WORKSPACE/validation.ok"
if [ ! -x "$WORKSPACE/run.sh" ]; then
  echo "run.sh missing" >&2; exit 2
fi
# Launch directly so $! is the real launched process. Capture PID.
# Use setsid to ensure process gets its own session so we can kill the group when cleaning up.
# The run.sh should prefer venv python; we launch it directly as requested.
setsid "$WORKSPACE/run.sh" >"$LOG" 2>&1 &
PID=$!
# stronger cleanup: send TERM to process group, give time, then SIGKILL
cleanup() {
  set +e
  if kill -0 "$PID" >/dev/null 2>&1; then
    # kill the process group to avoid orphaned GUI child processes
    PGID=$(ps -o pgid= -p "$PID" | tr -d ' ')
    if [ -n "$PGID" ]; then
      kill -TERM -"$PGID" >/dev/null 2>&1 || true
      sleep 1
      kill -0 "$PID" >/dev/null 2>&1 || true
      if kill -0 "$PID" >/dev/null 2>&1; then
        kill -KILL -"$PGID" >/dev/null 2>&1 || true
      fi
    else
      kill "$PID" >/dev/null 2>&1 || true
      sleep 1
      kill -9 "$PID" >/dev/null 2>&1 || true
    fi
  fi
}
trap cleanup EXIT
# wait up to TIMEOUT seconds for the expected log line
TIMEOUT=20
i=0
found=0
while [ $i -lt $TIMEOUT ]; do
  if grep -q "Tk app started" "$LOG" >/dev/null 2>&1; then
    found=1
    break
  fi
  sleep 1; i=$((i+1))
done
if [ $found -ne 1 ]; then
  echo "Validation failed: start message not found within ${TIMEOUT}s" >&2
  sed -n '1,200p' "$LOG" >&2 || true
  exit 8
fi
# ensure process still running for a short grace period
sleep 1
if ! kill -0 "$PID" >/dev/null 2>&1; then
  echo "Validation failed: process exited after start; see log" >&2
  sed -n '1,200p' "$LOG" >&2 || true
  exit 9
fi
# success artifact
echo "validation: success" > "$WORKSPACE/validation.ok"
# cleanup will run via trap on exit
