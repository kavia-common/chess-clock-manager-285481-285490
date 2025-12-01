#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="${WORKSPACE:-/home/kavia/workspace/code-generation/chess-clock-manager-285481-285490/tkniter_chess_clock_native_app}"
cd "$WORKSPACE"
KEEP_ALIVE=false
if [ "${1:-}" = "--keep-alive" ]; then KEEP_ALIVE=true; fi
mkdir -p "$WORKSPACE/validation-logs"
LOG_STDOUT="$WORKSPACE/validation-logs/app.stdout.log"
LOG_STDERR="$WORKSPACE/validation-logs/app.stderr.log"
export DISPLAY="${DISPLAY:-:99}"
if [ ! -x "$WORKSPACE/start.sh" ]; then echo 'start.sh missing or not executable' >&2; exit 13; fi
if [ -x "$WORKSPACE/.venv/bin/python" ]; then :; elif command -v python3 >/dev/null 2>&1; then :; else echo 'No python available to run the app' >&2; exit 14; fi
# start app in background capturing output
"$WORKSPACE/start.sh" >"$LOG_STDOUT" 2>"$LOG_STDERR" &
APP_PID=$!
sleep 2
if ! ps -p "$APP_PID" >/dev/null 2>&1; then
  echo "Application did not start (pid $APP_PID). See logs: $LOG_STDERR" >&2
  echo '--- STDERR tail ---' >>"$LOG_STDERR" || true
  tail -n 200 "$LOG_STDERR" || true
  exit 20
fi
ps -o pid,ppid,cmd -p "$APP_PID" >"$WORKSPACE/validation-logs/process.info.txt" || true
SNAP="$WORKSPACE/validation-logs/screen.xwd"
if command -v xwd >/dev/null 2>&1; then
  if xwd -root -display "$DISPLAY" -silent -out "$SNAP" >/dev/null 2>&1; then
    echo "xwd saved to $SNAP" >>"$WORKSPACE/validation-logs/snapshot.log" || true
  else
    echo 'xwd snapshot failed' >>"$WORKSPACE/validation-logs/snapshot.log" || true
  fi
else
  if command -v xdpyinfo >/dev/null 2>&1; then
    xdpyinfo -display "$DISPLAY" >"$WORKSPACE/validation-logs/xdpyinfo.txt" 2>&1 || true
  else
    echo 'No xwd or xdpyinfo available; snapshot skipped' >>"$WORKSPACE/validation-logs/snapshot.log" || true
  fi
fi
# collect log tails
echo '--- STDOUT tail ---' >"$WORKSPACE/validation-logs/log-tails.txt" || true
tail -n 200 "$LOG_STDOUT" >>"$WORKSPACE/validation-logs/log-tails.txt" || true
echo '--- STDERR tail ---' >>"$WORKSPACE/validation-logs/log-tails.txt" || true
tail -n 200 "$LOG_STDERR" >>"$WORKSPACE/validation-logs/log-tails.txt" || true
if [ "$KEEP_ALIVE" = true ]; then
  echo "validation_keep_alive pid=$APP_PID" >"$WORKSPACE/validation-logs/validation.status"
  echo "App left running (pid $APP_PID) for manual VNC inspection. Logs: $LOG_STDOUT $LOG_STDERR"
  exit 0
fi
TERM_TIMEOUT=8
kill -TERM "$APP_PID" >/dev/null 2>&1 || true
for i in $(seq 1 $TERM_TIMEOUT); do
  if ! ps -p "$APP_PID" >/dev/null 2>&1; then break; fi
  sleep 1
done
if ps -p "$APP_PID" >/dev/null 2>&1; then
  kill -KILL "$APP_PID" >/dev/null 2>&1 || true
fi
wait "$APP_PID" 2>/dev/null || true
echo 'validation_success' >"$WORKSPACE/validation-logs/validation.status"
