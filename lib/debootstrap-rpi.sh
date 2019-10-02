#!/bin/bash

set -e

rootfs=$1
dist=$2
mirror="http://archive.raspbian.org/raspbian"
include="fakeroot,build-essential,ca-certificates,git,cmake,dh-make,uuid-dev,libssl-dev,libcurl4-openssl-dev,curl"


if [ "$rootfs" == "" ]; then
	rootfs=$(realpath ./deboootstrap-rootfs)
fi

if [ "$dist" == "" ]; then
	dist="buster"
fi

if [ $EUID -ne 0 ]; then
	echo "This tool must be run as root."
	exit 1
fi

aptsources="deb http://archive.raspbian.org/raspbian ${dist} main contrib non-free\ndeb-src http://archive.raspbian.org/raspbian ${dist} main contrib non-free"

to_install="debootstrap qemu-user-static"

for p in $to_install; do
	if ! dpkg -s ${p} >/dev/null 2>&1; then
		apt install ${p}
	fi
done

debootstrap --arch armhf --foreign --include $include $dist $rootfs $mirror
cp /usr/bin/qemu-arm-static $rootfs/usr/bin
chroot $rootfs /debootstrap/debootstrap --second-stage
echo -e $aptsources > $rootfs/etc/apt/sources.list

chroot $rootfs apt update
