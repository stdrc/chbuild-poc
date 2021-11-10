#!/bin/bash

set -e

MUSL_CROSS_MAKE_INSTALL_DIR=/home/ipads/musl-cross-make-0.9.9/install
export PATH="$MUSL_CROSS_MAKE_INSTALL_DIR/bin:$PATH"

export PYTHONPATH=$CHPM_RECIPE_DIR/pylibs
BUILD_PYTHON="$(pwd)/build-pfb/install/bin/python3"
CROSS_PYTHON="$(pwd)/build/install/bin/python3"

echo "Creating cross venv..."
$BUILD_PYTHON -m pip config set global.index-url https://mirrors.sjtug.sjtu.edu.cn/pypi/web/simple
$BUILD_PYTHON -m crossenv $CROSS_PYTHON venv

echo "Installing build dependencies..."
# ./venv/build/bin/pip install numpy

echo "Installing bundled packages..."
./venv/cross/bin/pip install \
    requests flask bottle numpy

echo "Cleanup cache in temp install directory..."
find ./build/install -type d -name "__pycache__" | xargs rm -rf

echo "Copying files..."
cp -r ./build/install/* $CHPM_TARGET_PREFIX

echo "Copying site-packages..."
cp -r ./venv/cross/lib/python3.8/site-packages/* $CHPM_TARGET_PREFIX/lib/python3.8/site-packages/
