#!/bin/bash

set -e

dist=$1
azure_version=$2
tob_version=$3

if [ $EUID -ne 0 ]; then
	echo "This tool must be run as root."
	exit 1
fi

if [ "$#" != "3" ]; then
	echo "Usage: cross-build-all.sh distro azure_version trust_onboard_version"
	exit 1
fi

ROOTDIR=$(mktemp -d)
./lib/debootstrap-rpi.sh ${ROOTDIR} $dist
cp lib/cross-build-deb-azure.sh ${ROOTDIR}
chroot ${ROOTDIR} /cross-build-deb-azure.sh https://github.com/twilio/azure-iot-sdk-c cryptodev-debian azure-iot-sdk-c-twilio $azure_version

cp lib/cross-build-trust-onboard.sh ${ROOTDIR}
chroot ${ROOTDIR} /cross-build-trust-onboard.sh https://github.com/twilio/Breakout_Trust_Onboard_SDK "v${tob_version}" $tob_version -DOPENSSL_SUPPORT=ON -DBUILD_SHARED=ON

echo "Building debian packages is complete"
echo "Available packages:"

for d in ${ROOTDIR}/debs/*.deb; do
	echo " * $(realpath ${d})"
done

print "Delete ${ROOTDIR} after deploying the packages"
