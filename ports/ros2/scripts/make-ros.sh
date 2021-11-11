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
compiler_path=/home/ipads/musl-cross-make-0.9.9/install/bin
target_path=$(dirname $(readlink -f "$0"))/../
ros_install_path=$CHPM_BUILD_DIR/install

export PKG_CONFIG_PATH=$sysroot/lib/pkgconfig

cd $target_path

colcon build --packages-up-to demo_nodes_cpp examples_rclcpp_minimal_action_client examples_rclcpp_minimal_action_server \
    --packages-skip osrf_testing_tools_cpp \
    --event-handlers console_cohesion+ \
    --executor sequential \
    --merge-install \
    --cmake-args \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DCMAKE_C_COMPILER=$compiler_path/$target-gcc \
    -DCMAKE_CXX_COMPILER=$compiler_path/$target-g++ \
    -DCMAKE_SYSROOT=$sysroot \
    -DCMAKE_EXE_LINKER_FLAGS="-Wl,-rpath-link $ros_install_path/lib" \
    -DPYTHON_EXECUTABLE="/usr/bin/python3" \
    -DBUILD_TESTING:BOOL=OFF
