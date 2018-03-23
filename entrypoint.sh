#!/bin/bash

pushd ~/IncludeOS/etc/ > /dev/null
if version=$(grep -oP 'CLANG_VERSION_MIN_REQUIRED="\K[^"]+' install_dependencies_linux.sh); then :
elif version=$(grep -oP 'CLANG_VERSION="\K[^"]+' install_dependencies_linux.sh); then :
else version=3.8
fi
export CC=clang-$version
export CXX=clang++-$version
popd > /dev/null

exec "$@"
