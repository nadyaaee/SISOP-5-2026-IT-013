#!/bin/bash

if [ "$1" == "--single" ]; then
    qemu-system-x86_64 \
    -kernel osboot/bzImage \
    -initrd osboot/single.gz \
    -append "console=ttyS0" \
    -nographic \
    -netdev user,id=net0 \
    -device e1000,netdev=net0

elif [ "$1" == "--multi" ]; then
    qemu-system-x86_64 \
    -kernel osboot/bzImage \
    -initrd osboot/multi.gz \
    -append "console=ttyS0" \
    -nographic \
    -netdev user,id=net0 \
    -device e1000,netdev=net0

elif [ "$1" == "--all" ]; then
    qemu-system-x86_64 \
    -cdrom osboot/farewell.iso \
    -boot d \
    -nographic \
    -netdev user,id=net0 \
    -device e1000,netdev=net0

else
    echo "Cara pakai:"
    echo "./qemu.sh --single"
    echo "./qemu.sh --multi"
    echo "./qemu.sh --all"
fi
