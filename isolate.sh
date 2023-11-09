#!/bin/bash

if [[ $EUID > 0 ]]; then  
  echo "Please run as root/sudo"
  exit 1
fi

NS=$PWD/ns

# Need private bind mount for MNT namespace
mkdir -p $NS
mount --bind $NS $NS
mount --make-private $NS
for i in uts mnt pid net ipc user;
   do
      touch $NS/$i
   done


