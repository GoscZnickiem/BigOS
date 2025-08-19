#!/bin/bash
set -e

echo "(script): creating kernel partition..."
./create_kernel_partition.sh
echo "(script): creating boot partition..."
./create_boot_partition.sh

echo "(script): running qemu..."
qemu-system-riscv64 -machine virt -serial mon:stdio -nographic -m 2G -d int,cpu_reset,mmu -D qemu.log -kernel "../external/u-boot/u-boot.bin" -drive file=boot.img,format=raw,if=virtio -drive file=test.img,format=raw,if=virtio
