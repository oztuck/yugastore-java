#!/usr/bin/env bash
# Stops the Yugastore stack started by start-app.sh.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
PID_DIR="$REPO_ROOT/.run"

if [[ ! -d "$PID_DIR" ]]; then
  echo "No PID directory found at $PID_DIR; nothing to stop."
  exit 0
fi

for pidfile in "$PID_DIR"/*.pid; do
  [[ -e "$pidfile" ]] || continue
  module=$(basename "$pidfile" .pid)
  pid=$(cat "$pidfile")
  if kill -0 "$pid" 2>/dev/null; then
    echo "Stopping $module (pid $pid)"
    kill "$pid"
  else
    echo "$module (pid $pid) already stopped"
  fi
  rm -f "$pidfile"
done

echo "Done."
