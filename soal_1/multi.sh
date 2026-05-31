#!/bin/bash
set -e

BUSYBOX_VERSION="1.36.1"
BUSYBOX_DIR="busybox-$BUSYBOX_VERSION"
ROOTFS="multi_rootfs"

if [ ! -d "$BUSYBOX_DIR" ]; then
    wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
    tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
fi

cd "$BUSYBOX_DIR"
make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i 's/# CONFIG_FEATURE_SHADOWPASSWDS is not set/CONFIG_FEATURE_SHADOWPASSWDS=y/' .config
make -j$(nproc)
make CONFIG_PREFIX="../$ROOTFS" install
cd ..

mkdir -p $ROOTFS/{bin,dev,proc,sys,etc,tmp,root,home}
mkdir -p $ROOTFS/home/{henn,hann,viii,kids}
chmod 777 $ROOTFS/tmp
chmod 700 $ROOTFS/root

ROOT_HASH=$(openssl passwd -6 root123)
HENN_HASH=$(openssl passwd -6 henn123)
HANN_HASH=$(openssl passwd -6 hann123)
VIII_HASH=$(openssl passwd -6 viii123)
KIDS_HASH=$(openssl passwd -6 kids123)

cat > $ROOTFS/etc/passwd << EOF
root:x:0:0:root:/root:/bin/sh
henn:x:1000:1000:henn:/home/henn:/bin/sh
hann:x:1001:1001:hann:/home/hann:/bin/sh
viii:x:1002:1002:viii:/home/viii:/bin/sh
kids:x:1003:1003:kids:/home/kids:/bin/sh
EOF

cat > $ROOTFS/etc/shadow << EOF
root:$ROOT_HASH:19000:0:99999:7:::
henn:$HENN_HASH:19000:0:99999:7:::
hann:$HANN_HASH:19000:0:99999:7:::
viii:$VIII_HASH:19000:0:99999:7:::
kids:$KIDS_HASH:19000:0:99999:7:::
EOF

cat > $ROOTFS/etc/group << EOF
root:x:0:
henn:x:1000:henn
hann:x:1001:hann,henn
viii:x:1002:viii,hann,henn
kids:x:1003:kids,viii,hann,henn
EOF

chmod 600 $ROOTFS/etc/shadow

chown -R 0:0 $ROOTFS/root
chown -R 1000:1000 $ROOTFS/home/henn
chown -R 1001:1001 $ROOTFS/home/hann
chown -R 1002:1002 $ROOTFS/home/viii
chown -R 1003:1003 $ROOTFS/home/kids

chmod 700 $ROOTFS/root
chmod 770 $ROOTFS/home/henn
chmod 770 $ROOTFS/home/hann
chmod 770 $ROOTFS/home/viii
chmod 770 $ROOTFS/home/kids

cat > $ROOTFS/etc/inittab << 'EOF'
::sysinit:/etc/init.d/rcS
ttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
EOF

mkdir -p $ROOTFS/etc/init.d

cat > $ROOTFS/etc/init.d/rcS << 'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
hostname farewell
EOF

chmod +x $ROOTFS/etc/init.d/rcS

cat > $ROOTFS/etc/profile << 'EOF'
clear
echo "  ______                         _ _   ____            _"
echo " |  ____|                       | | | |  _ \          | |"
echo " | |__ __ _ _ __ _____      _____| | | | |_) |_ _ _ __| |_ _   _"
echo " |  __/ _\` | '__/ _ \ \ /\ / / _ \ | | |  __/ _\` | '__| __| | | |"
echo " | | | (_| | | |  __/\ V  V /  __/ | | | | | (_| | |  | |_| |_| |"
echo " |_|  \__,_|_|  \___| \_/\_/ \___|_|_| |_|  \__,_|_|   \__|\__, |"
echo "                                                            __/ |"
echo "                                                           |___/"
echo "Welcome, $(whoami). $(whoami)"
EOF

cat > $ROOTFS/init << 'EOF'
#!/bin/sh
exec /sbin/init
EOF

chmod +x $ROOTFS/init

cd $ROOTFS
find . | cpio -o -H newc | gzip > ../osboot/multi.gz
cd ..

rm -rf $ROOTFS

echo "Multi filesystem selesai: osboot/multi.gz"
