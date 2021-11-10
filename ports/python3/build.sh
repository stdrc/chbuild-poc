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

echo "Building \"Python for build\"..."
mkdir build-pfb
pushd build-pfb

../configure --prefix=$(pwd)/install
make -s -j$(nproc)
make install

if [ -f "./install/bin/python3.8" ]; then
    echo "Succeeded to build \"Python for build\""
else
    echo >&2 "Failed to build \"Python for build\""
    exit 1
fi

popd

echo "Building Python..."
mkdir build
pushd build

echo "Configuring..."
CPPFLAGS="-I$CHPM_TARGET_PREFIX/include" LDFLAGS="-L$CHPM_TARGET_PREFIX/lib" \
    ../configure \
    --build=$(gcc -dumpmachine) \
    --host=$(${CROSS_COMPILE}gcc -dumpmachine) \
    --prefix=$(pwd)/install \
    --disable-ipv6 \
    --disable-shared \
    --enable-optimizations \
    --with-ensurepip=no \
    ac_cv_file__dev_ptc=no \
    ac_cv_file__dev_ptmx=no \
    PYTHON_FOR_BUILD='_PYTHON_PROJECT_BASE=$(abs_builddir) _PYTHON_HOST_PLATFORM=$(_PYTHON_HOST_PLATFORM) PYTHONPATH=$(shell test -f pybuilddir.txt && echo $(abs_builddir)/`cat pybuilddir.txt`:)$(srcdir)/Lib:$(srcdir)/Lib/$(PLATDIR) ../build-pfb/install/bin/python3'

echo "Overriding pyconfig.h..."
cp -f $CHPM_RECIPE_DIR/pyconfig.chcore.h ./pyconfig.h

echo "Building..."
make -s -j$(nproc)

echo "Installing to temp install directory..."
make install

if [ -f "./install/bin/python3.8" ]; then
    echo "Succeeded to build Python"
else
    echo >&2 "Failed to build Python"
    exit 1
fi

popd
