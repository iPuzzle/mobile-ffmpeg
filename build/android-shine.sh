#!/bin/bash

if [[ -z $1 ]]; then
    echo "usage: $0 <mobile ffmpeg base directory>"
    exit 1
fi

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
    echo "ANDROID_NDK_ROOT not defined"
    exit 1
fi

if [[ -z ${ARCH} ]]; then
    echo "ARCH not defined"
    exit 1
fi

if [[ -z ${API} ]]; then
    echo "API not defined"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo "BASEDIR not defined"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/android-common.sh

# PREPARING PATHS & DEFINING ${INSTALL_PKG_CONFIG_DIR}
set_toolchain_clang_paths

# PREPARING FLAGS
TARGET_HOST=$(get_target_host)
export CFLAGS=$(get_cflags "shine")
export CXXFLAGS=$(get_cxxflags "shine")
export LDFLAGS=$(get_ldflags "shine")
export PKG_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}"

cd ${BASEDIR}/src/shine || exit 1

make distclean 2>/dev/null 1>/dev/null

./configure \
    --prefix=${ANDROID_NDK_ROOT}/prebuilt/android-$(get_target_build ${ARCH})/shine \
    --with-pic \
    --with-sysroot=${ANDROID_NDK_ROOT}/toolchains/mobile-ffmpeg-${TOOLCHAIN}/sysroot \
    --enable-static \
    --disable-shared \
    --disable-fast-install \
    --host=${TARGET_HOST} || exit 1

make -j$(nproc) || exit 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./*.pc ${INSTALL_PKG_CONFIG_DIR}

make install || exit 1