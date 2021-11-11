#!/bin/bash

set -e
source $CHPM_RECIPE_DIR/../musl_common.sh

echo "Compiling hello-chpm++..."
${CROSS_COMPILE}g++ -o hello-chpm++ $CHPM_RECIPE_DIR/hello_chpm.cpp
