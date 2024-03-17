#!/bin/bash -eu
set -a
CC=aarch64-linux-android32-clang
CXX=aarch64-linux-android32-clang++
AR=llvm-ar
STRIP=llvm-strip
set +a

curl -LO https://mirrors.edge.kernel.org/pub/linux/utils/kernel/kmod/kmod-32.tar.xz
tar xvf kmod-32.tar.xz
cd kmod-32

ruby <<'EOF'
files = `find . -name *.c`.lines(chomp: true)

files.each do |f|
  modded = File.read(f).sub('#include <stdio.h>', <<~REPLACE)
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>
    #include <limits.h>
    #define program_invocation_short_name getprogname()
    static char *get_current_dir_name(void) { return getcwd(malloc(PATH_MAX), PATH_MAX); }
  REPLACE

  modded.gsub!('/lib/modules', '/vendor/lib/modules')

  File.write(f, modded)
end
EOF

./configure \
  --host=aarch64-linux-android \
  --target=aarch64-linux-android \
  --prefix=/system \
  --bindir=/system/bin \
  --sbindir=/system/sbin \
  --libdir=/system/lib64 \
  --with-module-directory=/vendor/lib/modules \
  --disable-maintainer-mode \
  --disable-manpages \
  --disable-test-modules

make -j8
make DESTDIR=$PWD/destdir install-strip