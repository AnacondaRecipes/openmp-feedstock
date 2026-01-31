#!/bin/bash
set -ex

cd openmp/build

# Use BUILD_PREFIX cmake if cmake not in PATH (e.g., on osx where cmake
# is removed from output requirements to avoid circular dependency)
if command -v cmake &> /dev/null; then
  cmake --install .
else
  $BUILD_PREFIX/bin/cmake --install .
fi

rm -f $PREFIX/lib/libgomp$SHLIB_EXT

if [[ "$target_platform" == linux-* ]]; then
  # move libarcher.so so that it doesn't interfere
  mv $PREFIX/lib/libarcher.so $PREFIX/lib/libarcher.so.bak
fi
