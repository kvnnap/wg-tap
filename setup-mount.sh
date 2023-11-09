#!/bin/bash

cd $1
mount --bind root root
cd root
mkdir oldroot
pivot_root . oldroot
export PATH=$PATH
cd /
mount -t proc proc proc
mount -t sysfs sys sys
umount -l /oldroot
