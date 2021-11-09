#!/bin/bash

set -e

# Don't edit this unless you known what you're doing.
MUSL_CROSS_MAKE_INSTALL_DIR=/home/ipads/musl-cross-make-0.9.9/install

export PATH="$PATH:$MUSL_CROSS_MAKE_INSTALL_DIR/bin"

arch=$CHPM_TARGET_ARCH
if [ "$arch" = "aarch64" ]; then
    CROSS_COMPILE="aarch64-linux-musleabi-"
elif [ "$arch" = "x86_64" ]; then
    CROSS_COMPILE="x86_64-linux-musl-"
else
    echo >&2 "Unsupported architecture"
    exit 1
fi

CC=${CROSS_COMPILE}gcc \
    CXX=${CROSS_COMPILE}g++ \
    AR=${CROSS_COMPILE}ar \
    NM=${CROSS_COMPILE}nm \
    LD=${CROSS_COMPILE}ld \
    RANLIB=${CROSS_COMPILE}ranlib \
    ./configure --prefix=$CHPM_TARGET_PREFIX

make -j$(nproc)
