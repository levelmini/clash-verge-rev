#!/bin/bash

wget https://nodejs.org/dist/v20.10.0/node-v20.10.0-linux-x64.tar.xz
tar -Jxvf ./node-v20.10.0-linux-x64.tar.xz
export PATH=$(pwd)/node-v20.10.0-linux-x64/bin:$PATH
npm install pnpm -g

rustup target add "$INPUT_TARGET"
echo "rustc version: $(rustc --version)"

if [ "$INPUT_TARGET" = "x86_64-unknown-linux-gnu" ]; then
    apt-get update
    apt-get install -y libxdo-dev libssl-dev libayatana-appindicator3-dev librsvg2-dev libglib2.0-dev libgtk-3-dev libwebkit2gtk-4.1-dev libsoup-3.0-dev libjavascriptcoregtk-4.1-dev
    export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig
elif [ "$INPUT_TARGET" = "armv7-unknown-linux-gnueabihf" ]; then
    ls -lR /etc/apt/
    cat >/tmp/sources.list <<EOF
deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports jammy main multiverse universe restricted
deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports jammy-security main multiverse universe restricted
deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports jammy-updates main multiverse universe restricted
deb [arch=armhf,arm64] http://ports.ubuntu.com/ubuntu-ports jammy-backports main multiverse universe restricted
EOF
    mv /etc/apt/sources.list /etc/apt/sources.list.default
    mv /tmp/sources.list /etc/apt/sources.list
    dpkg --add-architecture armhf
    apt update

    apt-get install -y libxdo-dev:armhf libssl-dev:armhf libayatana-appindicator3-dev:armhf librsvg2-dev:armhf libglib2.0-dev:armhf libgtk-3-dev:armhf libwebkit2gtk-4.1-dev:armhf libsoup-3.0-dev:armhf libjavascriptcoregtk-4.1-dev:armhf
    export CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc
    export CC_armv7_unknown_linux_gnueabihf=arm-linux-gnueabihf-gcc
    export CXX_armv7_unknown_linux_gnueabihf=arm-linux-gnueabihf-g++
    export PKG_CONFIG_PATH=/usr/lib/arm-linux-gnueabihf/pkgconfig
    export PKG_CONFIG_ALLOW_CROSS=1

fi

bash .github/build-for-linux/build.sh
