#!/bin/bash
set -ex

cd openmp/build

if [[ "$target_platform" == osx-* ]]; then
  # cmake and ninja install both require cmake, which is unavailable in the
  # output build env on macOS (circular dep: cmake depends on llvm-openmp).
  # Use pre-staged installation from build.sh instead.
  cp -R $SRC_DIR/openmp/staged_install/* $PREFIX/
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
