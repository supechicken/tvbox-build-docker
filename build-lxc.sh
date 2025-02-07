#!/bin/bash -eu
set -a

AR=llvm-ar
STRIP=llvm-strip

set +a

git clone https://github.com/lxc/lxc -b v6.0.3 --single-branch --depth=1
cd lxc

cat <<'EOF' > cross.txt
[binaries]
c = 'aarch64-linux-android32-clang'
cpp = 'aarch64-linux-android32-clang++'
ar = 'llvm-ar'
strip = 'llvm-strip'

[host_machine]
system = 'android'
cpu_family = 'aarch64'
cpu = 'aarch64'
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

ls destdir/data/adb/modules/lxc/system/share/bash-* destdir/data/adb/modules/lxc/system/include destdir/data/adb/modules/lxc/system/lib64/pkgconfig
rm -rf destdir/data/adb/modules/lxc/system/share/bash-* destdir/data/adb/modules/lxc/system/include destdir/data/adb/modules/lxc/system/lib64/pkgconfig

mv destdir/data/adb/modules/lxc/system/bin/lxc-attach destdir/data/adb/modules/lxc/system/bin/lxc-attach.real
cat <<'EOF' > destdir/data/adb/modules/lxc/system/bin/lxc-attach
#!/system/bin/sh -eu

exec lxc-attach.real -e "${@}"
EOF

sed -i 
chmod +x destdir/data/adb/modules/lxc/system/bin/lxc-attach

find . -type f -exec sed -i 's,#!/bin/sh,#!/system/bin/sh,' {} \;
find . -type f -exec sed -i 's,#!/bin/bash,#!/system/bin/sh,' {} \;
