#!/bin/bash

set -e

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

./configure \
    --host=$(${CROSS_COMPILE}gcc -dumpmachine) \
    --prefix=$CHPM_TARGET_PREFIX \
    --disable-docs

make -j$(nproc)
