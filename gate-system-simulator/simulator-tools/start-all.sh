#!/bin/bash
# Simple launcher for the gate simulator
set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Starting backend..."
npm run start:backend >/tmp/gate-backend.log 2>&1 &
BACK_PID=$!

echo "Starting gate 1..."
npm run start:gate1 >/tmp/gate1.log 2>&1 &
G1_PID=$!

echo "Starting gate 2..."
npm run start:gate2 >/tmp/gate2.log 2>&1 &
G2_PID=$!

echo "Starting display UI server on http://127.0.0.1:8080 ..."
python -m http.server 8080 --directory display-ui/gate-display >/tmp/gate-display.log 2>&1 &
UI_PID=$!

trap 'echo \"Stopping...\"; kill $BACK_PID $G1_PID $G2_PID $UI_PID' INT
echo "All services launched. Press Ctrl+C to stop."
wait
