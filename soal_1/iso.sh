#!/bin/bash
set -e

ISO_DIR="iso_root"

rm -rf $ISO_DIR
mkdir -p $ISO_DIR/boot/grub

cp osboot/bzImage $ISO_DIR/boot/
cp osboot/single.gz $ISO_DIR/boot/
cp osboot/multi.gz $ISO_DIR/boot/

cat > $ISO_DIR/boot/grub/grub.cfg << 'EOF'
set timeout=5
set default=0

menuentry "Farewell Party - Single User" {
    linux /boot/bzImage console=ttyS0
    initrd /boot/single.gz
}

menuentry "Farewell Party - Multi User" {
    linux /boot/bzImage console=ttyS0
    initrd /boot/multi.gz
}
EOF

grub-mkrescue -o osboot/farewell.iso $ISO_DIR

rm -rf $ISO_DIR

echo "ISO selesai dibuat: osboot/farewell.iso"
