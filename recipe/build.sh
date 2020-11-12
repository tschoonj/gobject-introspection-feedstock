#! /bin/bash

set -ex

if [[ "$target_platform" == osx-* ]] ; then
    # dead_strip_dylibs breaks some tests
    LDFLAGS=${LDFLAGS//-Wl,-dead_strip_dylibs/}
fi

export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
    mkdir -p build-host
    pushd build-host

    # Store original flags
    export CC_ORIG=$CC
    export LDFLAGS_ORIG=$LDFLAGS
    export CFLAGS_ORIG=$CFLAGS
    export PKG_CONFIG_PATH_ORIG=$PKG_CONFIG_PATH

    export CC=$CC_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS

    meson --buildtype=release --prefix="$BUILD_PREFIX" --backend=ninja -Dlibdir=lib \
          -Dcairo=enabled -Dpython="$BUILD_PREFIX/bin/python" ..
    ninja
    ninja install

    # Restore original flags
    export CC=$CC_ORIG
    export LDFLAGS=$LDFLAGS_ORIG
    export CFLAGS=$CFLAGS_ORIG
    export PKG_CONFIG_PATH=$PKG_CONFIG_PATH_ORIG

    popd
    MESON_ARGS="-Dgi_cross_use_prebuilt_gi=True ${MESON_ARGS}"
fi

mkdir forgebuild
cd forgebuild
meson ${MESON_ARGS} --buildtype=release --prefix="$PREFIX" --backend=ninja -Dlibdir=lib \
      -Dcairo=enabled -Dpython="$BUILD_PREFIX/bin/python" ..
ninja -v
if [[ "$CONDA_BUILD_CROSS_COMPILATION" != 1 ]]; then
  ninja test
fi
ninja install

rm -f $PREFIX/lib/libgirepository-*.a $PREFIX/lib/libgirepository-*.la
