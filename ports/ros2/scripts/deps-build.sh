#!/bin/bash

set -e

if [ "$CHPM_TARGET_ARCH" = "aarch64" ]; then
    target=aarch64-linux-musleabi
    platform=aarch64
elif [ "$CHPM_TARGET_ARCH" = "x86_64" ]; then
    target=x86_64-linux-musl
    platform=x86_64
else
    echo >&2 "Unsupported architecture"
    exit 1
fi

sysroot=$CHPM_BUILD_DIR/sysroot
gcc_path=/home/ipads/musl-cross-make-0.9.9/install/$target
target_path=$(dirname $(readlink -f "$0"))

# sudo ln -sf $gcc_path /$target

mkdir -p $sysroot/lib
cp $gcc_path/lib/libstdc++.so* $sysroot/lib
cp $gcc_path/lib/libgcc_s.so* $sysroot/lib

mkdir -p $target_path/autogen-$platform

python $target_path/autogen.py $platform

$target_path/third-party-install.sh
