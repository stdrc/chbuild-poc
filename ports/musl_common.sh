#!/bin/bash

export PATH="$PATH:/home/ipads/musl-cross-make-0.9.9/install/bin"

if [ "$CHPM_TARGET_ARCH" = "aarch64" ]; then
    export CROSS_COMPILE="aarch64-linux-musleabi-"
elif [ "$CHPM_TARGET_ARCH" = "x86_64" ]; then
    export CROSS_COMPILE="x86_64-linux-musl-"
else
    echo >&2 "Unsupported architecture"
    exit 1
fi
