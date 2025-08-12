#!/bin/bash
set -e

IMG="test.img"
IMG_SIZE_MB=256
VOLUME_LABEL=KERNELVOL
LOOP_DEV=

cleanup() {
    if mountpoint -q kernel_tmp; then
        sudo umount kernel_tmp
    fi
    if [ -n "$LOOP_DEV" ]; then
        sudo losetup -d "$LOOP_DEV"
    fi
	rmdir kernel_tmp
}
trap cleanup EXIT

dd if=/dev/zero of=$IMG bs=1M count=$IMG_SIZE_MB

parted -s $IMG mklabel gpt
parted -s $IMG mkpart ext2-part ext2 1MiB 100%
parted -s $IMG name 1 $VOLUME_LABEL

LOOP_DEV=$(sudo losetup --find --partscan --show $IMG)
PART_DEV=${LOOP_DEV}p1

sleep 1

sudo mkfs.ext2 -L "$VOLUME_LABEL" $PART_DEV

mkdir kernel_tmp/
sudo mount $PART_DEV kernel_tmp/

sudo mkdir kernel_tmp/kernel_src/
sudo cp ../build/src/kernel/kernel kernel_tmp/kernel_src/kernel.elf

sudo mkdir -p kernel_tmp/boot/conf
sudo ln -s /kernel_src/kernel.elf kernel_tmp/boot/conf/kernel

UUID=$(sudo blkid -s PARTUUID -o value $PART_DEV)
python3 config_create.py $UUID

sync
