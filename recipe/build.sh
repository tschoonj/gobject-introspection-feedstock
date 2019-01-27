#! /bin/bash

set -ex

if [ $(uname) = Darwin ] ; then
    LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
else
    LDFLAGS="$LDFLAGS -Wl,-rpath-link,$PREFIX/lib"
fi

mkdir forgebuild
cd forgebuild
meson --buildtype=release --prefix="$PREFIX" --backend=ninja -Dlibdir=lib \
      -Dcairo=true -Dpython="$PYTHON" ..
ninja -v
ninja test
ninja install

rm -f $PREFIX/lib/libgirepository-*.a $PREFIX/lib/libgirepository-*.la
