#!/bin/bash
set -e

IMG="boot.img"
IMG_SIZE_MB=64
VOLUME_LABEL=BOOTPART
LOOP_DEV=

cleanup() {
    if mountpoint -q boot_tmp; then
        sudo umount boot_tmp
    fi
    if [ -n "$LOOP_DEV" ]; then
        sudo losetup -d "$LOOP_DEV"
    fi
	rmdir boot_tmp
}
trap cleanup EXIT

dd if=/dev/zero of=$IMG bs=1M count=$IMG_SIZE_MB

parted -s $IMG mklabel gpt
parted -s $IMG mkpart fat32-part fat32 1MiB 100%
parted -s $IMG name 1 $VOLUME_LABEL

LOOP_DEV=$(sudo losetup --find --partscan --show $IMG)
PART_DEV=${LOOP_DEV}p1

sleep 1

sudo mkfs.vfat -F 32 -n "$VOLUME_LABEL" $PART_DEV

mkdir boot_tmp/
sudo mount $PART_DEV boot_tmp/

sudo cp -r ../build/efidir/EFI boot_tmp/EFI
sudo mv conf.meta boot_tmp/EFI/BOOT/

sync
