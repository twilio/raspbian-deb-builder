#!/bin/bash

fail() {
	echo $1
	exit 1
}

set -e

git_source=$1
git_branch=$2
version=$3
dist=$4

license=mit
author_email=agerasimov@twilio.com

full_package_name=azure-iot-sdk-c-twilio-${version}

if [ "$#" != "4" ]; then
	echo "Usage: cross-build-deb-azure.sh git_repo_url git_branch version dist"
	exit 1
fi

if [ $EUID -ne 0 ]; then
	echo "This tool must be run as root."
	exit 1
fi

mkdir -p /debs
cd /debs
git clone --recursive ${git_source} -b ${git_branch} ${full_package_name}
tar czvf ${full_package_name}.tar.gz ${full_package_name}
cd ${full_package_name}
dh_make -y -l -c ${license} -e ${author_email} -f ../${full_package_name}.tar.gz
#magical line in Azure SDK, might be unnecessary
dh_make -y -l -c ${license} -e ${author_email} -f ../${full_package_name}.tar.gz || true

cp -r ./build_all/packaging/linux/debian ./
cat >./debian/changelog <<EOF
azure-iot-sdk-c-twilio (${version}.1${dist}) ${dist}; urgency=low

  * See tag ${git_branch} on https://github.com/twilio/Breakout_Trust_Onboard_SDK for source

 -- Anton Gerasimov <agerasimov@twilio.com> $(date -R)
EOF

if [ "$dist" == "stretch" ]; then
	sed -i -e 's/libssl-dev/libssl1.0-dev/g' ./debian/control
fi

dpkg-buildpackage -us -uc || fail "Building debian package failed"

# do we need a source package?
dpkg-buildpackage -S || fail "Building source package failed"
