#!/bin/bash
set -ex

cd openmp/build

# On osx, cmake is removed from output requirements to avoid circular dependency.
# Use ninja install directly since build uses Ninja generator.
if command -v cmake &> /dev/null; then
  cmake --install .
else
  # ninja should be available from main build requirements
  ninja install
fi

rm -f $PREFIX/lib/libgomp$SHLIB_EXT

if [[ "$target_platform" == linux-* ]]; then
  # move libarcher.so so that it doesn't interfere
  mv $PREFIX/lib/libarcher.so $PREFIX/lib/libarcher.so.bak
fi
