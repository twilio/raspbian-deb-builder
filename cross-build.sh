#!/bin/bash

set -e

dist=$1
products=${@:2}

if [ $EUID -ne 0 ]; then
	echo "This tool must be run as root."
	exit 1
fi

if [ "$#" -lt "2" ]; then
	echo "Usage: cross-build.sh distro prod1:ver1 [prod2:ver2 [...]]"
	echo "Available products:"
	echo "  * azure-iot-sdk-c"
	echo "  * breakout-tob-sdk"
	exit 1
fi

#ROOTDIR=$(mktemp -d)
ROOTDIR=/tmp/tmp.02M5xuiWZn/
#./lib/debootstrap-rpi.sh ${ROOTDIR} $dist

for prod in $products; do
	echo "PROD is ${prod}"
	prodname=$(echo "$prod" | cut -d':' -f1)
	prodver=$(echo "$prod" | cut -d':' -f2)
	case $prodname in
		"azure-iot-sdk-c")
			cp lib/cross-build-deb-azure.sh ${ROOTDIR}
			chroot ${ROOTDIR} /cross-build-deb-azure.sh https://github.com/twilio/azure-iot-sdk-c cryptodev-debian azure-iot-sdk-c-twilio $prodver
			;;
		"breakout-tob-sdk")
			cp lib/cross-build-trust-onboard.sh ${ROOTDIR}
			chroot ${ROOTDIR} /cross-build-trust-onboard.sh https://github.com/twilio/Breakout_Trust_Onboard_SDK "v${prodver}" $prodver -DOPENSSL_SUPPORT=ON -DBUILD_SHARED=ON
			;;
		*)
			echo "Unknown product, skipping"
		;;
	esac
done

echo "Building debian packages is complete"
echo "Available packages:"

for d in ${ROOTDIR}/debs/*.deb; do
	echo " * $(realpath ${d})"
done

echo "Delete ${ROOTDIR} after deploying the packages"
