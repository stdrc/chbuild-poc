#!/bin/bash

set -e

echo $(pwd)

echo "CHPM_PKG_NAME: $CHPM_PKG_NAME"
echo "CHPM_PKG_VERSION: $CHPM_PKG_VERSION"

echo "CHPM_RECIPE_FILE: $CHPM_RECIPE_FILE"
echo "CHPM_RECIPE_DIR: $CHPM_RECIPE_DIR"

echo "CHPM_BUILD_DIR: $CHPM_BUILD_DIR"

echo "CHPM_TARGET_ARCH: $CHPM_TARGET_ARCH"
echo "CHPM_TARGET_PREFIX: $CHPM_TARGET_PREFIX"

source $CHPM_RECIPE_DIR/../musl_common.sh

echo "CROSS_COMPILE: $CROSS_COMPILE"

echo "Compiling hello-chpm..."
${CROSS_COMPILE}gcc -o hello-chpm $CHPM_RECIPE_DIR/hello_chpm.c
