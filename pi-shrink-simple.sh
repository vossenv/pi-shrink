#!/bin/bash

# Pi Shrink
# Script intended to shrink image files from raspberry pi down
# to minimum size for storage and reuse on any SD card
# Credit for process to: https://softwarebakery.com//shrinking-images-on-linux
# Danimae Vosssen 2019

echo ""
echo "Pi Shrink v1.0.0"
echo "https://github.com/vossenv/pi-shrink"
echo "Based on: https://softwarebakery.com/shrinking-images-on-linux"

set -e

cleanup() {
	if [[ ! $? = 0 ]]; then		
   	losetup -d $dev &> /dev/null
	fi
}

compute () {
	echo "scale=$2; $1" | bc -l
}

trap "cleanup" EXIT

img=$1
dev=$(losetup -f)
modprobe loop;
losetup $dev $img;
partprobe $dev;

dev_parts=($(fdisk -l $dev | grep -Po "${dev}p[^\s]+")) 
part_count=${#dev_parts[@]}
part=${dev_parts[-1]}

blocksize=($(parted $dev print | grep "Sector size"))
blocksize=$(echo ${blocksize[-1]} | grep -Po "(?<=/)\d+")

initial=$(stat --printf="%s" $img)
target=$(resize2fs $part -P 2>&1 | grep -Po '(?<=filesystem:).*' | xargs)
target_kb=$(compute "$target*4 + ${blocksize}000" 0) 

e2fsck -fy $part
resize2fs $part -M 
parted -a opt $dev ---pretend-input-tty resizepart $part_count "${target_kb}kB"  Yes
resize2fs $part
losetup -d $dev
sleep 5

disk=($(fdisk -l $img | grep "img2"))
sz=$(compute "(${disk[2]}+1)*$blocksize" 0)
sz_gb=$(compute "$sz/1000000000" 3)
truncate --size=$sz $img

losetup $dev $img;
e2fsck -fy $part
losetup -d "$dev"

echo "Succesfully shrunk image to $sz_gb GB!"
echo ""