#!/bin/bash
set -e

BUSYBOX_VERSION="1.36.1"
BUSYBOX_DIR="busybox-$BUSYBOX_VERSION"
ROOTFS="single_rootfs"

if [ ! -d "$BUSYBOX_DIR" ]; then
    wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
    tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
fi

cd "$BUSYBOX_DIR"
make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
make -j$(nproc)
make CONFIG_PREFIX="../$ROOTFS" install
cd ..

mkdir -p $ROOTFS/{bin,dev,proc,sys,etc,tmp,root}
chmod 777 $ROOTFS/tmp
chmod 700 $ROOTFS/root

cat > $ROOTFS/init << 'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev

clear
echo "  ______                         _ _   ____            _"
echo " |  ____|                       | | | |  _ \          | |"
echo " | |__ __ _ _ __ _____      _____| | | | |_) |_ _ _ __| |_ _   _"
echo " |  __/ _\` | '__/ _ \ \ /\ / / _ \ | | |  __/ _\` | '__| __| | | |"
echo " | | | (_| | | |  __/\ V  V /  __/ | | | | | (_| | |  | |_| |_| |"
echo " |_|  \__,_|_|  \___| \_/\_/ \___|_|_| |_|  \__,_|_|   \__|\__, |"
echo "                                                            __/ |"
echo "                                                           |___/"
echo "Welcome, root. root"

exec /bin/sh
EOF

chmod +x $ROOTFS/init

cd $ROOTFS
find . | cpio -o -H newc | gzip > ../osboot/single.gz
cd ..

rm -rf $ROOTFS

echo "Single filesystem selesai: osboot/single.gz"
