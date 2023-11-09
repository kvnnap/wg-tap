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

if [ ! -d "/sys/class/net/$BRNAME" ] 
then
    echo "$BRNAME does not exist, doing NOTHING" 
    exit 0
fi

ip link del $BRNAME
ip address add $IPNET dev $DEV
ip route add default via $GATEWAY
