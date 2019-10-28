#!/bin/bash

set -e

git_source=$1
git_branch=$2
version=$3
dist=$4
# the rest are cmake flags
cmake_flags=${@:5}

apt-get -y install azure-iot-sdk-c-twilio-dev nlohmann-json-dev

mkdir -p /debs
cd /debs
git clone --recursive ${git_source} -b ${git_branch} breakout-tob
cd breakout-tob
mkdir cmake; cd cmake
cmake -DCMAKE_INSTALL_PREFIX=/usr -DCPACK_PACKAGE_VERSION="${version}.1${dist}" $cmake_flags ..
make -j4
cpack
mv *.deb ../..
