#!/bin/bash

cd /

/app/add-br.sh veth0 192.168.0.8/24 192.168.0.1

apk --no-cache add wireguard-tools

echo "Starting up tunnel interface.."
ln -s /proc/self/fd /dev/fd
wg-quick up peer7

echo "Setting up gretap"
ip link add gtaptun type gretap remote 10.13.13.5 local 10.13.13.8
ip link set gtaptun down
ip link set dev gtaptun up master br0

trap '[[ $SLEEP_PID ]] && kill $SLEEP_PID' SIGTERM
sleep infinity &
SLEEP_PID=$!
wait $SLEEP_PID
wait $SLEEP_PID

ip link del gtaptun
ip link del veth0
wg-quick down peer7
