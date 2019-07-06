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

usage="
Pi Shrink is a script to shrink Raspberry Pi images to minimum size...

usage:
./pi-shrink.sh myimage.img [-h] [-d]

where:
    -h, --help  show this help text
    -d, --debug  shows all operations\n\n"

no_copy=0
while [[ $# -gt 0 ]]; do
  key=$1
  case $key in
       --help|-h) 
                printf "$usage"
                exit 
                ;;
      --debug|-d)
                set -exu
                shift ;;
  --no-copy|-nc)
                no_copy=1
                shift ;;    
              *)
                img=$key
                set -eu
                shift;;		
  esac
done

cleanup() {
	if [[ ! $? = 0 ]]; then
		printColor "Critical error! Unmounting $dev and exiting... \n\n" red
   	losetup -d $dev &> /dev/null
	fi
}

compute () {
	echo "scale=$2; $1" | bc -l
}

printColor(){
    case $2 in
        "black") col=0;;
          "red") col=1;;
        "green") col=2;;
       "yellow") col=3;;
         "blue") col=4;;
      "magenta") col=5;;
         "cyan") col=6;;
        "white") col=7;;
              *) col=7;;
    esac
    printf "$(tput setaf $col)$1$(tput sgr 0)\n"
}

printBanner() {
	sep="------------------------------------------------------------------"	
	printColor "$1\n$sep" green	
}

#### Script begins here

trap "cleanup" EXIT
header_color="cyan"

if [[ ! -f "$img" ]]; then
	echo "Error! $img not found... "
	exit
fi


if [[ "$no_copy" = 0 ]]; then
  printBanner "\nPreparing image... "
  filename="shrunk_${img}"
  [[ -f "$filename" ]] && rm $filename
  echo "Making a copy of the original... "
  echo "Image will be called $filename"
  rsync --info=progress2 $img $filename
  echo "Finished clone, sleeping 5s for disk activity to cease... "
  sleep 5
  img=$filename
fi

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
target_mb=$(compute "$target_kb/1000" 2)
target_gb=$(compute "$target_kb/1000000" 2)
initial_mb=$(compute "$initial/1000000" 2)
initial_gb=$(compute "$initial/1000000000" 3)

printBanner "\nDevice details"
parted $dev print

printBanner "Partition details"
echo "Image file: $img"
echo "Mounted as loop on: $dev"
echo "Partitions: $part_count"
echo "Target partion: $part"
echo "Initial size: $initial_mb MB / $initial_gb GB"
echo "Target size: $target_mb MB / $target_gb GB"
echo ""

read -p "Proceed (y/n)[y]? " yn
case $yn in
	[Yy]|Yes|yes|'' );;
	* ) losetup -d $dev; exit;;
esac

printBanner "\nBegin processsing"
printColor "Preparing filesystem... " $header_color
e2fsck -fy $part

printColor "\nShrinking filesystem to minimum size... " $header_color
resize2fs $part -M 

printColor "Shrinking partition to ${target_mb} MB... " $header_color
parted -a opt $dev ---pretend-input-tty resizepart $part_count "${target_kb}kB"  Yes

printColor "Expanding filesystem to fill partition..." $header_color
resize2fs $part

printColor "Unmounting $dev... " $header_color
losetup -d $dev

echo "Waiting for 5s unmount... "
sleep 5

printColor "\nTruncating raw image file..." $header_color
disk=($(fdisk -l $img | grep "img2"))
sz=$(compute "(${disk[2]}+1)*$blocksize" 0)
sz_gb=$(compute "$sz/1000000000" 3)

echo "Final size will be $sz_gb GB"
truncate --size=$sz $img

printColor "\nFinalize... " $header_color
losetup $dev $img;
e2fsck -fy $part
echo "Unmounting $dev... "
losetup -d "$dev"

printBanner "\nProcess complete!"
echo "Succesfully shrunk image from $initial_gb GB to $sz_gb GB!"
echo ""