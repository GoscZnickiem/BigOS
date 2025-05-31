#!/bin/bash
set -e

IMG=test.img
IMG_SIZE_MB=64
VOLUME_LABEL=KERNELVOL
LOOP_DEV=

cleanup() {
    if mountpoint -q tmp; then
        sudo umount tmp
    fi
    if [ -n "$LOOP_DEV" ]; then
        sudo losetup -d "$LOOP_DEV"
    fi
	rmdir tmp
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

mkdir tmp/
sudo mount $PART_DEV tmp/

sudo mkdir tmp/test_src/
echo "Hello World" | sudo tee tmp/test_src/file > /dev/null

sudo mkdir tmp/test/
sudo ln -s tmp/test_src/file tmp/test/link

sudo blkid $PART_DEV

sync
