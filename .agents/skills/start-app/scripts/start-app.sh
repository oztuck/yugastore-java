#!/usr/bin/env bash
# Starts the full Yugastore stack (Eureka, microservices, react-ui) on macOS/Linux.
# Assumes each module has already been built (target/*.jar exists) and that
# YugabyteDB is already running (see the setup-local skill).
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
LOG_DIR="$REPO_ROOT/logs"
PID_DIR="$REPO_ROOT/.run"
mkdir -p "$LOG_DIR" "$PID_DIR"

# Services started first, one at a time, then the remaining four together.
EUREKA="eureka-server-local"
CORE_SERVICES=(api-gateway-microservice products-microservice checkout-microservice cart-microservice)
UI="react-ui"

start_jar() {
  local module="$1"
  local dir="$REPO_ROOT/$module"
  local jar
  jar=$(ls "$dir"/target/"$module"-*.jar 2>/dev/null | grep -v '\.original$' | head -n1)
  if [[ -z "$jar" ]]; then
    echo "Skipping $module: no jar found in $dir/target. Build it first." >&2
    return 1
  fi
  echo "Starting $module ($jar)"
  # cd and the background launch must be separate statements: if they were
  # chained with '&&' before the '&', bash would background a subshell
  # wrapper and $! would capture that wrapper's pid instead of java's.
  (
    cd "$dir"
    nohup java -jar "$jar" > "$LOG_DIR/$module.log" 2>&1 &
    echo $! > "$PID_DIR/$module.pid"
  )
}

wait_for_log() {
  local module="$1"
  local pattern="$2"
  local timeout="${3:-60}"
  local log="$LOG_DIR/$module.log"
  echo "Waiting for $module to be ready..."
  for ((i = 0; i < timeout; i++)); do
    if grep -qE "$pattern" "$log" 2>/dev/null; then
      echo "$module is up."
      return 0
    fi
    sleep 1
  done
  echo "Warning: $module did not report readiness within ${timeout}s; check $log" >&2
  return 1
}

# Spring Boot logs "Started <MainClass> in N.NNN seconds" on every module
# regardless of class name, so this pattern works generically for all of them.
READY_PATTERN='Started [A-Za-z0-9_]+ in [0-9.]+ seconds'

start_jar "$EUREKA"
wait_for_log "$EUREKA" "$READY_PATTERN" 60

for svc in "${CORE_SERVICES[@]}"; do
  start_jar "$svc"
done
echo "Waiting for microservices to register with Eureka..."
sleep 15

start_jar "$UI"
wait_for_log "$UI" "$READY_PATTERN" 60

echo
echo "All services launched. Logs: $LOG_DIR  PIDs: $PID_DIR"
echo "Eureka dashboard: http://localhost:8761/eureka/apps"
echo "App entry point (gateway): http://localhost:8081"
echo "React UI (if served standalone): http://localhost:8080"
echo "Use scripts/stop-app.sh to stop everything."
