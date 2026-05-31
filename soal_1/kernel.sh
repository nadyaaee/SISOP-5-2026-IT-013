#!/bin/bash
set -e

KERNEL_VERSION="6.1.1"
KERNEL_DIR="linux-$KERNEL_VERSION"

if [ ! -d "$KERNEL_DIR" ]; then
    wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
    tar -xf linux-$KERNEL_VERSION.tar.xz
fi

cd "$KERNEL_DIR"

make x86_64_defconfig

scripts/config --enable CONFIG_DEVTMPFS
scripts/config --enable CONFIG_DEVTMPFS_MOUNT
scripts/config --enable CONFIG_NET
scripts/config --enable CONFIG_INET
scripts/config --enable CONFIG_E1000
scripts/config --enable CONFIG_FUSE_FS

make olddefconfig
make -j$(nproc)

cd ..
cp "$KERNEL_DIR/arch/x86/boot/bzImage" osboot/bzImage

echo "Kernel selesai dibuat: osboot/bzImage"
