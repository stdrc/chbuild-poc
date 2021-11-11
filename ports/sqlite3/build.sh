#!/bin/bash

set -e
source $CHPM_RECIPE_DIR/../musl_common.sh

cp $CHPM_RECIPE_DIR/Makefile ./
make CC=${CROSS_COMPILE}gcc AR=${CROSS_COMPILE}ar

${CROSS_COMPILE}gcc $CHPM_RECIPE_DIR/test.c \
        -o test-sqlite3 \
        -I. -L. -lsqlite3
