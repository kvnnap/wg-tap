#!/bin/bash

if [[ $EUID > 0 ]]; then  
  echo "Please run as root/sudo"
  exit 1
fi

trap '[[ $SLEEP_PID ]] && kill $SLEEP_PID' SIGTERM
sleep infinity &
SLEEP_PID=$!
wait $SLEEP_PID

echo "Waiting for sleep to exit"
wait $SLEEP_PID

echo "Starting entrypoint"

export PATH=$PATH
exec env -i /app/ash-init.sh
