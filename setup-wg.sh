#!/bin/ash

echo "Starting up tunnel interface.."
wg-quick up client

echo "Setting up bridging"
ip link add gtaptun type gretap remote 10.13.13.5 local 10.13.13.8
ip link set eth0 down
ip address del 192.168.1.9/24 dev eth0
ip link set gtaptun down
ip link add name br0 type bridge
ip link set dev eth0 master br0
ip link set dev gtaptun master br0
ip address add 192.168.1.9/24 dev br0
ip link set eth0 up
ip link set gtaptun up
ip link set br0 up
ip route add default via 192.168.1.254

echo "Starting up crond"
trap '[[ $CRON_PID ]] && kill $CRON_PID' SIGTERM
crond -f -l 2 &
CRON_PID=$!
wait $CRON_PID

echo "Closing down tunnel interface.."
wg-quick down client

