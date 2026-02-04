#!/bin/bash
set -ex

cd openmp/build

# Install on osx is done during build to avoid output cmake deps.
if [[ "$target_platform" != osx-* ]]; then
  if [[ -x "$BUILD_PREFIX/bin/cmake" ]]; then
    "$BUILD_PREFIX/bin/cmake" --install .
  elif command -v cmake &> /dev/null; then
    cmake --install .
  else
    # ninja should be available from main build requirements
    ninja install
  fi
fi

rm -f $PREFIX/lib/libgomp$SHLIB_EXT

if [[ "$target_platform" == linux-* ]]; then
  # move libarcher.so so that it doesn't interfere
  mv $PREFIX/lib/libarcher.so $PREFIX/lib/libarcher.so.bak
fi
