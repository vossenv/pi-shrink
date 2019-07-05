img=$1

sep="------------------------------------------------------------------"
echo ""

compute () {
	echo "scale=$2; $1" | bc -l
}

# img='test.img';
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
initial_gb=$(compute "$initial/1000000000" 2)

printf "Device details\n$sep\n"

parted $dev print

echo "" 
printf "Partition details\n$sep\n"
echo "Image file: $img"
echo "Mounted as loop on: $dev"
echo "Partitions: $part_count"
echo "Target partion: $part"
echo "Initial size: $initial_mb MB / $initial_gb GB"
echo "Target size: $target_mb MB / $target_gb GB"

echo ""
echo "Shrinking filesystem to minimum size... "
resize2fs $part -M 

echo "Shrinking partition to ${target_mb} MB... "
parted -a opt $dev ---pretend-input-tty resizepart $part_count "${target_kb}kB" Yes

echo "Expanding filesystem to fill partition..."
resize2fs $part

echo "Truncating raw image file..."
disk=($(fdisk -l test.img | grep "img2"))
truncate --size=$[(${disk[2]}+1)*$blocksize] $img

printf "Check filesystem...\n$sep\n"
fsck $part

echo "Unmounting $dev..."
losetup -d $dev

echo "Process complete!"
echo "" 