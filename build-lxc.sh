#!/bin/bash -eu
TARGET=x86

set -a

if [[ "${TARGET}" == 'x86' ]]; then
  CC=x86_64-linux-android33-clang
  CXX=x86_64-linux-android33-clang++
  BUILD_TARGET=x86_64-linux-android
else
  CC=aarch64-linux-android32-clang
  CXX=aarch64-linux-android32-clang++
  BUILD_TARGET=aarch64-linux-android
fi

AR=llvm-ar
STRIP=llvm-strip

set +a

git clone https://github.com/lxc/lxc -b lxc-4.0.12 --single-branch --depth=1
cd lxc
mkdir destdir

./autogen.sh
./configure \
  --host="$BUILD_TARGET" \
  --target="$BUILD_TARGET" \
  --prefix=/system \
  --bindir=/system/bin \
  --sbindir=/system/sbin \
  --libdir=/system/lib64 \
  --localstatedir=/data/local/var \
  --with-runtime-path=/data/local/run \
  --with-distro=android \
  --with-init-script='' \
  --enable-strip \
  --disable-werror \
  --disable-apparmor \
  --disable-capabilities \
  --disable-seccomp \
  --disable-selinux \
  --disable-openssl \
  --disable-doc \
  --disable-api-docs \
  --disable-bash \
  --disable-examples

sed -i 's/#include "fexecve.h"//' src/lxc/rexec.c

make -j8
make -i DESTDIR=$PWD/destdir install-strip
