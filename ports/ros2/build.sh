#!/bin/bash

set -e

mv ros2/* ./

rm -rf scripts
cp -r $CHPM_RECIPE_DIR/scripts ./

./scripts/deps-build.sh
./scripts/make-ros.sh
