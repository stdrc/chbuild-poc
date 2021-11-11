#!/bin/bash

set -e
source $CHPM_RECIPE_DIR/../musl_common.sh

mkdir -p $CHPM_TARGET_PREFIX/{include,lib}
cp sqlite3.h $CHPM_TARGET_PREFIX/include
cp libsqlite3.a $CHPM_TARGET_PREFIX/lib
cp libsqlite3.so $CHPM_TARGET_PREFIX/lib

mkdir -p $CHPM_TARGET_PREFIX/apps
cp test-sqlite3 $CHPM_TARGET_PREFIX/apps
