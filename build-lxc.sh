#!/bin/bash -eu
set -a

AR=llvm-ar
STRIP=llvm-strip

set +a

git clone https://github.com/lxc/lxc -b v6.0.3 --single-branch --depth=1
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
  -Dprefix=/data/adb/modules/lxc/system \
  -Dlibdir=/data/adb/modules/lxc/system/lib64 \
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

ls destdir/system/share/bash-* destdir/system/include destdir/system/lib64/pkgconfig
rm -rf destdir/system/share/bash-* destdir/system/include destdir/system/lib64/pkgconfig

mv destdir/system/bin/lxc-attach destdir/system/bin/lxc-attach.real
cat <<'EOF' > destdir/system/bin/lxc-attach
#!/system/bin/sh -eu

exec lxc-attach.real -e "${@}"
EOF

sed -i 
chmod +x destdir/system/bin/lxc-attach
