#!/bin/bash

CONFIG="/home/rolly/dwl/config.def.h"
LOG="/home/rolly/dwl/rebuild.log"

{
echo "[trigger] at $(date)"
echo "  PWD: $(pwd)"
echo "  Args: $@"

# Check if file actually changed recently
echo "  Checking if $CONFIG modified in last 2s..."
if ! find "$CONFIG" -mmin -0.03 | grep -q .; then
  echo "[watcher] False trigger skipped at $(date)"
  echo "  (File not changed within threshold)"
  exit 0
fi

echo "[trigger] Passed recent-modified check"

cd /home/rolly/dwl || {
  echo "[error] Failed to cd to /home/rolly/dwl"
  exit 1
}

echo "[trigger] Removing config.h"
rm -f config.h

echo "[trigger] Running make clean"
sudo make clean

echo "[trigger] Running make"
sudo make || {
  echo "[error] make failed"
  exit 1
}

echo "[trigger] Running make install"
sudo make install || {
  echo "[error] make install failed"
  exit 1
}

  echo "[trigger] restarting dwl"
  pkill dwl
  sleep 1
  slstatus -s | dwl &

} >> "$LOG" 2>&1

