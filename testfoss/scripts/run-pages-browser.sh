#!/usr/bin/env bash
set -euo pipefail

TESTFOSS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(cd "$TESTFOSS_ROOT/.." && pwd)"
TOOLS="$TESTFOSS_ROOT/.tools"
RESULTS="$TESTFOSS_ROOT/results"
PORT="${LAMMPS_PAGES_PORT:-4173}"
export PATH="$TOOLS/lmctl/node_modules/.bin:$TOOLS/bin:$PATH"
export LAMMPS_PAGES_URL="${LAMMPS_PAGES_URL:-http://127.0.0.1:$PORT}"

command -v lmscript > /dev/null
command -v lmwebtest > /dev/null
mkdir -p "$RESULTS"
cd "$ROOT/examples/pages"
npm run preview -- --host 127.0.0.1 --port "$PORT" --strictPort > "$RESULTS/server.log" 2>&1 &
SERVER_PID=$!
trap 'kill "$SERVER_PID" 2> /dev/null || true; wait "$SERVER_PID" 2> /dev/null || true' EXIT
for _ in $(seq 1 60); do
  if curl --fail --silent --output /dev/null "$LAMMPS_PAGES_URL/"; then
    break
  fi
  if ! kill -0 "$SERVER_PID" 2> /dev/null; then
    cat "$RESULTS/server.log"
    exit 1
  fi
  sleep 1
done
curl --fail --silent --output /dev/null "$LAMMPS_PAGES_URL/"
cd "$ROOT"
lmscript "$TESTFOSS_ROOT/browser/pages.lms"
