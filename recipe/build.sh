#! /bin/bash

set -ex

if [[ "$target_platform" == osx-* ]] ; then
    # dead_strip_dylibs breaks some tests
    LDFLAGS=${LDFLAGS//-Wl,-dead_strip_dylibs/}
fi

mkdir forgebuild
cd forgebuild
meson ${MESON_ARGS} --buildtype=release --prefix="$PREFIX" --backend=ninja -Dlibdir=lib \
      -Dcairo=enabled -Dpython="$PYTHON" ..
ninja -v
ninja test
ninja install

rm -f $PREFIX/lib/libgirepository-*.a $PREFIX/lib/libgirepository-*.la
