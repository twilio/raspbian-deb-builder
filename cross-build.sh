#!/bin/bash

set -e

dist=$1
products=${@:2}

if [ $EUID -ne 0 ]; then
	echo "This tool must be run as root." >&2
	exit 1
fi

if [ "$#" -lt "2" ]; then
	echo "Usage: cross-build.sh distro prod1:branch1:ver1 [prod2:branch2:ver2 [...]]" >&2
	echo "Available products:" >&2
	echo "  * azure-iot-sdk-c" >&2
	echo "  * breakout-tob-sdk" >&2
	exit 1
fi

ROOTDIR=$(mktemp -d)
./lib/debootstrap-rpi.sh ${ROOTDIR} $dist >&2

for prod in $products; do
	prodname=$(echo "$prod" | cut -d':' -f1)
	prodbranch=$(echo "$prod" | cut -d':' -f2)
	prodver=$(echo "$prod" | cut -d':' -f3)
	case $prodname in
		"azure-iot-sdk-c")
			cp lib/cross-build-deb-azure.sh ${ROOTDIR}
			chroot ${ROOTDIR} /cross-build-deb-azure.sh https://github.com/twilio/azure-iot-sdk-c ${prodbranch} ${prodver} ${dist} >&2
			;;
		"breakout-tob-sdk")
			cp lib/cross-build-trust-onboard.sh ${ROOTDIR}
			chroot ${ROOTDIR} /cross-build-trust-onboard.sh https://github.com/twilio/Breakout_Trust_Onboard_SDK ${prodbranch} ${prodver} ${dist} -DOPENSSL_SUPPORT=ON -DBUILD_SHARED=ON >&2
			;;
		*)
			echo "Unknown product, skipping" >&2
			;;
	esac
done

echo "Building debian packages is complete" >&2
echo -e "Printing the list of available packages to the standard output\n\n" >&2

for d in ${ROOTDIR}/debs/*.deb; do
	echo "$(realpath ${d})"
done

echo "Delete ${ROOTDIR} after deploying the packages" >&2
