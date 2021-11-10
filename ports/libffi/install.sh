#!/bin/bash

set -e

MUSL_CROSS_MAKE_INSTALL_DIR=/home/ipads/musl-cross-make-0.9.9/install
export PATH="$MUSL_CROSS_MAKE_INSTALL_DIR/bin:$PATH"

make install
