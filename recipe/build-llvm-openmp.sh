mkdir build
cd build

if [[ "${target_platform}" == "osx-64" ]]; then
  # See https://github.com/AnacondaRecipes/aggregate/issues/107
  export CPPFLAGS="-mmacosx-version-min=10.9 -I${PREFIX}/include -D_FORTIFY_SOURCE=2"

  cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_C_FLAGS="-mlinker-version=305" \
    -DCMAKE_CXX_FLAGS="-mlinker-version=305" \
    ..
fi

if [[ "${target_platform}" == "linux"* ]]; then
  export LDFLAGS="$LDFLAGS -static-libgcc -static-libstdc++"
  cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    ..
fi

make -j${CPU_COUNT}
make install

rm -f $PREFIX/lib/libgomp$SHLIB_EXT

mkdir -p $PREFIX/lib/clang/$PKG_VERSION/include
# Standalone libomp build doesn't put omp.h in clang's default search path
cp $PREFIX/include/omp.h $PREFIX/lib/clang/$PKG_VERSION/include
