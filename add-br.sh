#!/bin/bash

if [[ $EUID > 0 ]]; then  
  echo "Please run as root/sudo"
  exit 1
fi

# example eth0 192.168.0.5/24 192.168.0.1
DEV=$1
IPNET=$2
GATEWAY=$3
BRNAME=br0

# improve using https://superuser.com/questions/1720967/how-does-linux-determine-the-default-mac-address-of-a-bridge-device
#service dhcpcd stop

if [ -d "/sys/class/net/$BRNAME" ] 
then
    echo "$BRNAME exists already, doing NOTHING" 
    exit 0
fi

ip link set $DEV down
ip address del $IPNET dev $DEV
# alpine cannot put interface up while adding a link.. so, 2 steps
ip link add name $BRNAME address $(cat /sys/class/net/$DEV/address) type bridge
ip link set dev $BRNAME up
ip link set dev $DEV up master $BRNAME
ip address add $IPNET dev $BRNAME
ip route add default via $GATEWAY

