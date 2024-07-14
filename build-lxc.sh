#!/bin/bash -eu
TARGET=x86

set -a

AR=llvm-ar
STRIP=llvm-strip

set +a

git clone https://github.com/lxc/lxc -b v6.0.1 --single-branch --depth=1
cd lxc

cat <<'EOF' > cross.txt
[binaries]
c = 'x86_64-linux-android33-clang'
cpp = 'x86_64-linux-android33-clang++'
ar = 'llvm-ar'
strip = 'llvm-strip'

[host_machine]
system = 'android'
cpu_family = 'x86_64'
cpu = 'x86_64'
endian = 'little'
EOF

meson setup --cross-file=cross.txt builddir \
  -Dbuildtype=release \
  -Dstrip=true \
  -Db_lto=true \
  -Dprefix=/system \
  -Dlibdir=/system/lib64 \
  -Dlocalstatedir=/data/local/var \
  -Druntime-path=/data/local/run \
  -Dcoverity-build=false \
  -Dexamples=false \
  -Dinit-script=[] \
  -Dman=false \
  -Dtests=false \
  -Ddbus=false \
  -Dspecfile=false \
  -Dtools-multicall=true \
  -Dcapabilities=false \
  -Dseccomp=false \
  -Dapparmor=false \
  -Dopenssl=false \
  -Dselinux=false

vim builddir/config.h
ninja -C builddir
DESTDIR=$PWD/destdir ninja -C builddir install

echo destdir/system/share/bash-*
rm -rf destdir/system/share/bash-*
