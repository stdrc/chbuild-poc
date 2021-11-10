#!/bin/bash

set -e
source $CHPM_RECIPE_DIR/../musl_common.sh

CC=${CROSS_COMPILE}gcc \
    CXX=${CROSS_COMPILE}g++ \
    AR=${CROSS_COMPILE}ar \
    NM=${CROSS_COMPILE}nm \
    LD=${CROSS_COMPILE}ld \
    RANLIB=${CROSS_COMPILE}ranlib \
    ./configure --prefix=$CHPM_TARGET_PREFIX

make -j$(nproc)
