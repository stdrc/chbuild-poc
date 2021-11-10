#!/bin/bash

set -e
source $CHPM_RECIPE_DIR/../musl_common.sh

./configure \
    --host=$(${CROSS_COMPILE}gcc -dumpmachine) \
    --prefix=$CHPM_TARGET_PREFIX \
    --disable-docs

make -j$(nproc)
