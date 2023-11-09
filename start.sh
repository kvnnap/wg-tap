#!/bin/bash

THIS_DIR=$PWD
CHILD_NAME=alpine
GATEWAY=192.168.0.1
HOSTIP=192.168.0.5/24
HOSTDEV=eth0
PEERDEV=veth0
BRDEV=br0
PEERIP=192.168.0.8/24

# Add host bridge
echo "Adding host bridge"
sudo service dhcpcd stop
sudo ./add-br.sh $HOSTDEV $HOSTIP $GATEWAY

# Add namespaces and bind the network one
CHILD_PID=$(unshare -Urnmp sh -c './init.sh > /dev/null & echo $!')
echo "CHILD_PID: $CHILD_PID"
sudo mkdir -p /var/run/netns
sudo touch /var/run/netns/$CHILD_NAME
sudo mount --bind /proc/$CHILD_PID/ns/net /var/run/netns/$CHILD_NAME

echo "Setting up child network namespace"
# Setup child namespace network
# ip netns add $CHILD_NAME
sudo ip link add vhost$CHILD_NAME type veth peer name $PEERDEV
sudo ip link set $PEERDEV netns $CHILD_NAME
sudo ip link set dev vhost$CHILD_NAME up master $BRDEV
sudo ip netns exec $CHILD_NAME ip link set dev lo up
#sudo ip netns exec $CHILD_NAME ip link set vns$CHILD_NAME name $PEERDEV
sudo ip netns exec $CHILD_NAME ip link set dev $PEERDEV up
# run dhclient to get ip (ONCE)
#sudo ip netns exec $CHILD_NAME dhclient -1 -v $PEERDEV
sudo ip netns exec $CHILD_NAME ip address add $PEERIP dev $PEERDEV
sudo ip netns exec $CHILD_NAME ip route add default via $GATEWAY

sudo umount /var/run/netns/$CHILD_NAME
sudo rm /var/run/netns/$CHILD_NAME

echo "Preparing alpine rootfs"
# Prepare alpine root fs
TAR_NAME=alpine-minirootfs-3.18.4-armv7.tar.gz
rm -rf $TAR_NAME root
wget https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/armv7/$TAR_NAME
mkdir root
tar -xf $TAR_NAME -C root
echo "nameserver 1.1.1.1" > root/etc/resolv.conf

# Add entry point
mkdir -p root/app
cp ash-init.sh add-br.sh entry.sh root/app/
mkdir -p root/etc/wireguard
cp peer7.conf root/etc/wireguard/

echo "Setting up mount namespace"
nsenter --preserve-credentials -t $CHILD_PID -U -m -p -n $THIS_DIR/setup-mount.sh $THIS_DIR
#nsenter --preserve-credentials -t $CHILD_PID -U -m -p -n /app/ash-init.sh

echo "Done. Resuming child init.sh script"
kill -s SIGTERM $CHILD_PID
