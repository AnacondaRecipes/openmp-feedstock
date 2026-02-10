#!/bin/bash
set -ex

cd openmp/build

if [[ "$target_platform" == osx-* ]]; then
  # cmake is not in output build requirements on osx (circular dep issue),
  # but it exists in BUILD_PREFIX from top-level build requirements
  "$BUILD_PREFIX/bin/cmake" --install .
else
  if [[ -x "$BUILD_PREFIX/bin/cmake" ]]; then
    "$BUILD_PREFIX/bin/cmake" --install .
  elif command -v cmake &> /dev/null; then
    cmake --install .
  else
    ninja install
  fi
fi

rm -f $PREFIX/lib/libgomp$SHLIB_EXT

if [[ "$target_platform" == linux-* ]]; then
  # move libarcher.so so that it doesn't interfere
  mv $PREFIX/lib/libarcher.so $PREFIX/lib/libarcher.so.bak
fi
