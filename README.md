# SISOP-5-2026-IT-013
Laporan Resmi Praktikum Sistem Operasi Modul 5

## Penulis
Nadya Putri Agustin \
5027251013



## Soal 1
### Isi `kernel.sh`
Script yang digunakan untuk mengunduh dan mengompilasi kernel Linux 6.1.1. Hasil dari proses ini adalah file `bzImage` yang berfungsi sebagai kernel utama sistem operasi dan disimpan pada folder `osboot/`.
```
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
```
Keterangan:

`#!/bin/bash`: Menentukan bahwa script dijalankan menggunakan Bash shell.

`set -e`: Jika ada satu perintah yang error, script langsung berhenti sehingga proses tidak dilanjutkan ke langkah berikutnya.

`KERNEL_VERSION="6.1.1"`: Menyimpan versi kernel Linux yang akan digunakan.

`KERNEL_DIR="linux-$KERNEL_VERSION"`: Membuat nama folder kernel berdasarkan versi yang telah ditentukan.

```
if [ ! -d "$KERNEL_DIR" ]; then
    wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VERSION.tar.xz
    tar -xf linux-$KERNEL_VERSION.tar.xz
fi
```

Mengecek apakah folder kernel sudah tersedia. Jika direktori belum ada, maka source code kernel Linux akan diunduh dari website resmi Linux Kernel dan kemudian diekstrak.

`cd "$KERNEL_DIR"`: Masuk ke direktori source code kernel Linux.

`make x86_64_defconfig`: Membuat konfigurasi default kernel untuk arsitektur x86_64 (64 bit).

`scripts/config --enable CONFIG_DEVTMPFS`: Mengaktifkan dukungan `devtmpfs   agar file perangkat pada direktori `/dev` dapat dibuat secara otomatis.

`scripts/config --enable CONFIG_DEVTMPFS_MOUNT`: Mengaktifkan proses mount `devtmpfs` secara otomatis saat sistem melakukan booting.

`scripts/config --enable CONFIG_NET`: Mengaktifkan fitur jaringan pada kernel Linux.

`scripts/config --enable CONFIG_INET`: Mengaktifkan dukungan protokol internet (TCP/IP dan IPv4).

`scripts/config --enable CONFIG_E1000`: Mengaktifkan driver kartu jaringan Intel E1000 yang umum digunakan pada lingkungan virtual seperti QEMU.

`scripts/config --enable CONFIG_FUSE_FS`: Mengaktifkan dukungan Filesystem in Userspace (FUSE).

`make olddefconfig`: Memperbarui file konfigurasi kernel dan mengisi opsi baru dengan nilai default yang sesuai.

`make -j$(nproc)`: Melakukan proses kompilasi kernel dengan memanfaatkan seluruh core prosesor yang tersedia agar proses build lebih cepat.

`cd ..`: Kembali ke direktori sebelumnya setelah proses kompilasi selesai.

`cp "$KERNEL_DIR/arch/x86/boot/bzImage" osboot/bzImage`: Menyalin file kernel hasil kompilasi (`bzImage`) ke folder `osboot`.

`echo "Kernel selesai dibuat: osboot/bzImage"`: Menampilkan pesan bahwa proses pembuatan kernel telah berhasil diselesaikan.


### Isi `single.sh`
Script yang digunakan untuk membuat filesystem single-user menggunakan BusyBox. Script ini membuat struktur direktori dasar Linux seperti `/bin`, `/dev`, `/proc`, `/sys`, `/etc`, `/tmp`, dan `/root`, kemudian menghasilkan file `single.gz` sebagai initramfs untuk mode single-user.
```
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
```

`BUSYBOX_VERSION="1.36.1"`: Menyimpan versi BusyBox yang akan digunakan.

`BUSYBOX_DIR="busybox-$BUSYBOX_VERSION"`: Membuat nama folder BusyBox berdasarkan versinya.

`ROOTFS="single_rootfs"`: Menentukan nama direktori root filesystem yang akan dibuat.

```
if [ ! -d "$BUSYBOX_DIR" ]; then
    wget https://busybox.net/downloads/busybox-$BUSYBOX_VERSION.tar.bz2
    tar -xf busybox-$BUSYBOX_VERSION.tar.bz2
fi
```

Mengecek apakah folder BusyBox sudah ada atau belum. Jika direktori belum ada, source code BusyBox akan diunduh dari website resmi BusyBox kemudian diekstrak.

`cd "$BUSYBOX_DIR"`: Masuk ke direktori source code BusyBox.

`make defconfig`: Membuat konfigurasi default BusyBox.

```
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
```

Mengubah konfigurasi BusyBox agar menggunakan static linking sehingga dapat berjalan tanpa membutuhkan library eksternal.

`make -j$(nproc)`: Melakukan proses kompilasi BusyBox dengan memanfaatkan seluruh core prosesor yang tersedia agar proses build lebih cepat.

```
make CONFIG_PREFIX="../$ROOTFS" install
```

Menginstal hasil build BusyBox ke dalam direktori root filesystem yang telah ditentukan.

`cd ..`: Kembali ke direktori sebelumnya.

```
mkdir -p $ROOTFS/{bin,dev,proc,sys,etc,tmp,root}
```

Membuat struktur direktori dasar Linux yang diperlukan oleh sistem seperti `/bin`, `/dev`, `/proc`, `/sys`, `/etc`, `/tmp`, dan `/root`.

```
chmod 777 $ROOTFS/tmp
```

Memberikan izin penuh pada direktori `/tmp` agar dapat digunakan untuk menyimpan file sementara.

```
chmod 700 $ROOTFS/root
```

Memberikan hak akses penuh hanya kepada pengguna root pada direktori `/root`.

```
cat > $ROOTFS/init << 'EOF'
...
EOF
```

Membuat file `init` yang akan dijalankan pertama kali oleh kernel setelah proses booting selesai.

```
mount -t proc none /proc
```

Melakukan mount filesystem `/proc` yang berisi informasi proses dan kernel.

```
mount -t sysfs none /sys
```

Melakukan mount filesystem `/sys` yang berisi informasi perangkat keras dan driver kernel.

```
mount -t devtmpfs none /dev
```

Melakukan mount filesystem `/dev` agar perangkat dapat dikenali dan digunakan oleh sistem.

`clear`: Membersihkan tampilan terminal saat sistem mulai berjalan.

`echo "..."`: Menampilkan ASCII art dan pesan sambutan ketika sistem berhasil booting.

```
exec /bin/sh
```

Menjalankan shell BusyBox sehingga pengguna dapat berinteraksi dengan sistem operasi.

```
chmod +x $ROOTFS/init
```

Memberikan izin eksekusi pada file `init`.

`cd $ROOTFS`: Masuk ke direktori root filesystem.

```
find . | cpio -o -H newc | gzip > ../osboot/single.gz
```

Mengubah seluruh isi root filesystem menjadi arsip initramfs menggunakan format `cpio`, kemudian mengompresnya menjadi file `single.gz`.

`cd ..`: Kembali ke direktori sebelumnya.

```
rm -rf $ROOTFS
```

Menghapus direktori root filesystem sementara karena seluruh isinya sudah dikemas ke dalam file `single.gz`.

```
echo "Single filesystem selesai: osboot/single.gz"
```

Menampilkan pesan bahwa proses pembuatan single filesystem berhasil dan file hasilnya tersimpan pada `osboot/single.gz`.

### Isi `multi.sh`
Script yang digunakan untuk membuat filesystem multi-user menggunakan BusyBox. Selain membuat struktur direktori dasar, script ini juga menambahkan beberapa akun pengguna yaitu `root`, `henn`, `hann`, `viii`, dan `kids` beserta password dan hak akses masing-masing. Hasil akhirnya berupa file `multi.gz`.
```
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
```

```
sed -i 's/# CONFIG_FEATURE_SHADOWPASSWDS is not set/CONFIG_FEATURE_SHADOWPASSWDS=y/' .config
```

Mengaktifkan fitur shadow password pada BusyBox agar password user dapat disimpan di file `/etc/shadow`.

```
mkdir -p $ROOTFS/home/{henn,hann,viii,kids}
```
Membuat direktori home untuk masing-masing user, yaitu `henn`, `hann`, `viii`, dan `kids`.

```
ROOT_HASH=$(openssl passwd -6 root123)
HENN_HASH=$(openssl passwd -6 henn123)
HANN_HASH=$(openssl passwd -6 hann123)
VIII_HASH=$(openssl passwd -6 viii123)
KIDS_HASH=$(openssl passwd -6 kids123)
```
Membuat password terenkripsi untuk setiap user menggunakan algoritma SHA-512. Password yang dibuat kemudian disimpan dalam variabel masing-masing.

```
cat > $ROOTFS/etc/passwd << EOF
...
EOF
```
Membuat file `/etc/passwd` yang berisi data user seperti username, UID, GID, home directory, dan shell yang digunakan.

```
cat > $ROOTFS/etc/shadow << EOF
...
EOF
```
Membuat file `/etc/shadow` yang berisi password terenkripsi dari setiap user.

```
cat > $ROOTFS/etc/group << EOF
...
EOF
```
Membuat file `/etc/group` yang berisi daftar grup dan anggota user pada sistem.

`chmod 600 $ROOTFS/etc/shadow`: Memberikan hak akses terbatas pada file `/etc/shadow` agar hanya root yang dapat membaca dan menulis file tersebut.

```
chown -R 0:0 $ROOTFS/root
```
Mengatur pemilik direktori `/root` menjadi user root dan group root.

```
chown -R 1000:1000 $ROOTFS/home/henn
chown -R 1001:1001 $ROOTFS/home/hann
chown -R 1002:1002 $ROOTFS/home/viii
chown -R 1003:1003 $ROOTFS/home/kids
```

Mengatur kepemilikan direktori home agar sesuai dengan UID dan GID masing-masing user.

`chmod 700 $ROOTFS/root`: Mengatur agar direktori `/root` hanya dapat diakses oleh root.

```
chmod 770 $ROOTFS/home/henn
chmod 770 $ROOTFS/home/hann
chmod 770 $ROOTFS/home/viii
chmod 770 $ROOTFS/home/kids
```

Memberikan hak akses penuh kepada pemilik dan grup pada masing-masing direktori home, sedangkan user lain tidak memiliki akses.

```
cat > $ROOTFS/etc/inittab << 'EOF'
...
EOF
```

Membuat file konfigurasi `inittab` yang digunakan oleh init untuk menjalankan proses awal sistem dan login terminal.

```
::sysinit:/etc/init.d/rcS
```

Menjalankan script `/etc/init.d/rcS` saat sistem pertama kali booting.

```
ttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100
```

Menjalankan proses login pada terminal serial `ttyS0`. Jika proses berhenti, maka akan dijalankan ulang secara otomatis.

```
::restart:/sbin/init
```

Menjalankan ulang init ketika sistem melakukan restart.

```
::ctrlaltdel:/sbin/reboot
```

Melakukan reboot ketika menerima perintah Ctrl + Alt + Del.

```
mkdir -p $ROOTFS/etc/init.d
```

Membuat direktori untuk menyimpan script inisialisasi sistem.

```
cat > $ROOTFS/etc/init.d/rcS << 'EOF'
...
EOF
```

Membuat script `rcS` yang berisi perintah awal saat sistem booting.

`mount -t proc none /proc`: Melakukan mount filesystem `/proc` yang berisi informasi proses dan kernel.

`mount -t sysfs none /sys`: Melakukan mount filesystem `/sys` yang berisi informasi perangkat keras dan driver kernel.

`mount -t devtmpfs none /dev`: Melakukan mount filesystem `/dev` agar perangkat dapat dikenali oleh sistem.

`hostname farewell`: Mengatur nama host sistem menjadi `farewell`.

`chmod +x $ROOTFS/etc/init.d/rcS`: Memberikan izin eksekusi pada file `rcS`.

```
cat > $ROOTFS/etc/profile << 'EOF'
...
EOF
```

Membuat file `/etc/profile` yang dijalankan saat user berhasil login.

`clear`: Membersihkan tampilan terminal setelah user login.

`echo "..."`: Menampilkan ASCII art sebagai tampilan awal sistem.

```
echo "Welcome, $(whoami). $(whoami)"
```

Menampilkan pesan sambutan sesuai dengan user yang sedang login.

```
cat > $ROOTFS/init << 'EOF'
#!/bin/sh
exec /sbin/init
EOF
```

Membuat file `init` utama yang akan menjalankan `/sbin/init` sebagai proses pertama saat sistem booting.

`chmod +x $ROOTFS/init`: Memberikan izin eksekusi pada file `init`.

`cd $ROOTFS`: Masuk ke direktori root filesystem.

```
find . | cpio -o -H newc | gzip > ../osboot/multi.gz
```

Mengubah seluruh isi root filesystem menjadi arsip initramfs menggunakan format `cpio`, kemudian mengompresnya menjadi file `multi.gz`.

`cd ..`: Kembali ke direktori sebelumnya.

`rm -rf $ROOTFS`: Menghapus direktori root filesystem sementara karena seluruh isinya sudah dikemas menjadi file `multi.gz`.

```
echo "Multi filesystem selesai: osboot/multi.gz"
```

Menampilkan pesan bahwa proses pembuatan multi filesystem berhasil dan file hasilnya tersimpan pada `osboot/multi.gz`.


### Isi `iso.sh`
Script yang digunakan untuk membuat file ISO bootable. Script ini menggabungkan kernel (`bzImage`) dan filesystem (`single.gz` dan `multi.gz`) ke dalam image ISO sehingga sistem operasi dapat dijalankan melalui menu boot. Hasilnya adalah file `farewell.iso`.
```
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
```

`ISO_DIR="iso_root"`: Menentukan nama direktori sementara yang digunakan untuk menyusun isi file ISO.

```
rm -rf $ISO_DIR
```

Menghapus direktori ISO sementara jika masih ada dari proses sebelumnya agar tidak terjadi konflik data.

```
mkdir -p $ISO_DIR/boot/grub
```
Membuat struktur direktori yang dibutuhkan oleh GRUB, yaitu direktori `/boot/grub`.

```
cp osboot/bzImage $ISO_DIR/boot/
```
Menyalin file kernel Linux (`bzImage`) ke direktori boot pada ISO.

```
cp osboot/single.gz $ISO_DIR/boot/
```
Menyalin file initramfs untuk mode Single User ke direktori boot.

```
cp osboot/multi.gz $ISO_DIR/boot/
```
Menyalin file initramfs untuk mode Multi User ke direktori boot.

```
cat > $ISO_DIR/boot/grub/grub.cfg << 'EOF'
...
EOF
```
Membuat file konfigurasi GRUB yang berisi menu boot sistem operasi.

```
set timeout=5
```
Mengatur waktu tunggu menu GRUB selama 5 detik sebelum memilih menu default.

```
set default=0
```
Menentukan menu pertama sebagai pilihan default saat booting.

```
menuentry "Farewell Party - Single User" {
    linux /boot/bzImage console=ttyS0
    initrd /boot/single.gz
}
```
Membuat menu boot **Single User**. Saat dipilih, GRUB akan memuat kernel `bzImage` dan initramfs `single.gz`.

```
menuentry "Farewell Party - Multi User" {
    linux /boot/bzImage console=ttyS0
    initrd /boot/multi.gz
}
```
Membuat menu boot **Multi User**. Saat dipilih, GRUB akan memuat kernel `bzImage` dan initramfs `multi.gz`.

```
grub-mkrescue -o osboot/farewell.iso $ISO_DIR
```
Membuat file ISO bootable menggunakan GRUB berdasarkan isi direktori `iso_root`. Hasil akhirnya disimpan dengan nama `farewell.iso`.

```
rm -rf $ISO_DIR
```
Menghapus direktori sementara `iso_root` karena proses pembuatan ISO telah selesai.

```
echo "ISO selesai dibuat: osboot/farewell.iso"
```
Menampilkan pesan bahwa proses pembuatan file ISO berhasil dan hasilnya tersimpan pada `osboot/farewell.iso`.
### Isi `qemu.sh`
Script yang digunakan untuk menjalankan sistem operasi menggunakan QEMU. Script ini menyediakan tiga mode boot:
- --single → menjalankan filesystem single-user.
- --multi → menjalankan filesystem multi-user.
- --all → menjalankan file ISO dan menampilkan menu boot.

```
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
```

```
if [ "$1" == "--single" ]; then
```
Mengecek apakah argumen yang diberikan saat menjalankan script adalah `--single`.

```
qemu-system-x86_64 \
```
Menjalankan emulator QEMU dengan arsitektur x86_64 (64 bit).

```
-kernel osboot/bzImage
```
Menggunakan file kernel Linux `bzImage` yang telah dibuat sebelumnya.

```
-initrd osboot/single.gz
```
Menggunakan file initramfs `single.gz` yang berisi root filesystem mode Single User.

```
-append "console=ttyS0"
```
Mengirim parameter kernel agar seluruh output ditampilkan melalui terminal serial `ttyS0`.

```
-nographic
```
Menjalankan QEMU tanpa tampilan grafis sehingga seluruh interaksi dilakukan melalui terminal.

```
-netdev user,id=net0
```
Membuat jaringan virtual menggunakan mode user networking.

```
-device e1000,netdev=net0
```
Menggunakan kartu jaringan virtual Intel E1000 yang terhubung ke jaringan virtual `net0`.

Bagian ini digunakan untuk menjalankan sistem operasi dalam mode **Single User**.

```
elif [ "$1" == "--multi" ]; then
```
Mengecek apakah argumen yang diberikan adalah `--multi`.

```
qemu-system-x86_64 \
    -kernel osboot/bzImage \
    -initrd osboot/multi.gz \
```
Menjalankan kernel Linux dengan root filesystem `multi.gz` yang mendukung banyak pengguna (multi user).

```
-append "console=ttyS0"
-nographic
-netdev user,id=net0
-device e1000,netdev=net0
```
Parameter ini memiliki fungsi yang sama seperti mode Single User, yaitu menampilkan output pada terminal dan mengaktifkan jaringan virtual.

Bagian ini digunakan untuk menjalankan sistem operasi dalam mode Multi User.

```
elif [ "$1" == "--all" ]; then
```
Mengecek apakah argumen yang diberikan adalah `--all`.

```
qemu-system-x86_64 \
```
Menjalankan emulator QEMU.

```
-cdrom osboot/farewell.iso
```
Menggunakan file ISO `farewell.iso` sebagai media boot.

```
-boot d
```
Mengatur agar proses boot dilakukan dari CD ROM atau file ISO.

```
-nographic
```
Menjalankan QEMU tanpa tampilan grafis dan menggunakan terminal sebagai media interaksi.

```
-netdev user,id=net0
-device e1000,netdev=net0
```
Mengaktifkan jaringan virtual menggunakan driver Intel E1000.

Bagian ini digunakan untuk menjalankan sistem operasi melalui menu GRUB yang terdapat pada file ISO.

```
else
```
Dijalankan jika pengguna tidak memberikan argumen yang benar.

```
echo "Cara pakai:"
echo "./qemu.sh --single"
echo "./qemu.sh --multi"
echo "./qemu.sh --all"
```
Menampilkan petunjuk penggunaan script beserta daftar argumen yang tersedia.

Script ini berfungsi untuk menjalankan sistem operasi menggunakan QEMU dalam tiga mode, yaitu Single User, Multi User, dan Boot melalui ISO (GRUB Menu).

### Isi `backup.sh`
Script yang digunakan untuk membuat arsip backup dari seluruh hasil build. File yang dibackup meliputi `bzImage`, `single.gz`, `multi.gz`, dan `farewell.iso`. Hasil backup disimpan dalam format ZIP dengan nama `farewell_backup_[DDMMYYYY-HHMMSS].zip`.
```
#!/bin/bash
set -e

TIME=$(date +"%d%m%Y-%H%M%S")
ZIPNAME="farewell_backup_[$TIME].zip"

cd osboot
zip "$ZIPNAME" bzImage single.gz multi.gz farewell.iso
echo "Backup selesai: osboot/$ZIPNAME"
```

`#!/bin/bash`: Menentukan bahwa script dijalankan menggunakan Bash shell.

`set -e`: Jika ada satu perintah yang error, script langsung berhenti sehingga proses backup tidak dilanjutkan.

```
TIME=$(date +"%d%m%Y-%H%M%S")
```
Mengambil tanggal dan waktu saat ini dengan format `ddmmyyyy-jammenitdetik` untuk digunakan pada nama file backup.

Contoh hasil:
```
04062026-143025
```

```
ZIPNAME="farewell_backup_[$TIME].zip"
```
Membuat nama file backup berdasarkan waktu saat backup dilakukan.

Contoh hasil:
```
farewell_backup_[04062026-143025].zip
```

```
cd osboot
```
Masuk ke direktori `osboot` yang berisi seluruh file hasil build sistem operasi.

```
zip "$ZIPNAME" bzImage single.gz multi.gz farewell.iso
```
Membuat file ZIP yang berisi:
- `bzImage` → file kernel Linux hasil kompilasi.
- `single.gz` → initramfs untuk mode Single User.
- `multi.gz` → initramfs untuk mode Multi User.
- `farewell.iso` → file ISO bootable yang berisi menu GRUB.

Seluruh file tersebut dikompres menjadi satu file backup dengan nama yang telah dibuat sebelumnya.

```
echo "Backup selesai: osboot/$ZIPNAME"
```
Menampilkan pesan bahwa proses backup berhasil dilakukan beserta nama file backup yang dihasilkan.

Script ini berfungsi untuk membuat backup seluruh file penting hasil build sistem operasi ke dalam satu file ZIP sehingga dapat disimpan atau dipindahkan dengan lebih mudah.

## Output
Jalankan:
```
./kernel.sh
```
![App Screenshot](https://github.com/nadyaaee/SISOP-5-2026-IT-013/blob/main/soal_1/Assets/kernel.png?raw=true)

Jalankan:
```
./single.sh
```
![App Screenshot](https://github.com/nadyaaee/SISOP-5-2026-IT-013/blob/main/soal_1/Assets/single.png?raw=true)

Jalankan:
```
./multi.sh
```
atau
```
sudo ./multi.sh
```
![App Screenshot](https://github.com/nadyaaee/SISOP-5-2026-IT-013/blob/main/soal_1/Assets/multi.png?raw=true)

Jalankan:
```
./iso.sh
```
![App Screenshot](https://github.com/nadyaaee/SISOP-5-2026-IT-013/blob/main/soal_1/Assets/iso.png?raw=true)

Tes
```
./qemu.sh --single
```
![App Screenshot](https://github.com/nadyaaee/SISOP-5-2026-IT-013/blob/main/soal_1/Assets/qemu-single.png?raw=true)

```
./qemu.sh --multi
```
![App Screenshot](https://github.com/nadyaaee/SISOP-5-2026-IT-013/blob/main/soal_1/Assets/qemu-multi.png?raw=true)

```
./qemu.sh --all
```
![App Screenshot](https://github.com/nadyaaee/SISOP-5-2026-IT-013/blob/main/soal_1/Assets/qemu-all.png?raw=true)

Keluar dari QEMU:
```
Ctrl + A lalu X
```

Jalankan:
```
./backup.sh
```
![App Screenshot](https://github.com/nadyaaee/SISOP-5-2026-IT-013/blob/main/soal_1/Assets/backup.png?raw=true)


#### Tes Akses Folder
Untuk tes user lain, harus logout dulu.
```
exit
```

1. Test root bisa akses semua

Login:
```
root
root123
```
Tes:
```
cd /root
cd /home/henn
cd /home/hann
cd /home/viii
cd /home/kids
```
Expected: semua berhasil.

2. Test user henn

Login:
```
henn
henn123
```
Tes:
```
whoami
cd /home/henn
touch test.txt
```
Expected:
```
henn
```
dan file berhasil dibuat.

Lalu:
```
cd /root
```
Expected:
```
Permission denied
```

3. Test user hann

Login:
```
hann
hann123
```
Tes:
```
cd /home/hann
cd /home/viii
cd /home/kids
```
Expected: berhasil.

Tes:
```
cd /home/henn
cd /root
```
Expected: gagal.

4. Test user viii

Login:
```
viii
viii123
```
Tes:
```
cd /home/viii
cd /home/kids
```
Expected: berhasil.

Tes:
```
cd /home/henn
cd /home/hann
cd /root
```
Expected: gagal.

5. Test user kids

Login:
```
kids
kids123
```
Tes:
```
cd /home/kids
```
Expected: berhasil.

Tes:
```
cd /home/henn
cd /home/hann
cd /home/viii
cd /root
```
Expected: gagal.

6. Test folder `/tmp`

Semua user:
```
cd /tmp
touch coba.txt
ls
```
Expected: berhasil karena soal menyebut semua user full access ke `/tmp`.

#### Tes Isi Backup 
```
unzip -l osboot/farewell_backup_*.zip
```
Expected ada:
```
bzImage
single.gz
multi.gz
farewell.iso
```
![App Screenshot](https://github.com/nadyaaee/SISOP-5-2026-IT-013/blob/main/soal_1/Assets/isi-zip.png?raw=true)
