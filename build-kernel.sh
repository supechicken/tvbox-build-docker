#!/bin/bash -eu
set -eu

rm -rf kernel tcp-brutal r8125-9.012.04

mkdir kernel
tar xf rk35xx-android12-266e2bf-20240115-kernel.tar.zst -C kernel

(
  cd kernel
  sed -i 's/static mali_bool mali_executor_is_working()/static mali_bool mali_executor_is_working(void)/' drivers/gpu/arm/mali400/mali/common/mali_executor.c

  curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
  cp ../kernelconfig .config

  make ARCH=arm64 LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- Image -j8
  make ARCH=arm64 LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH="$PWD/out-modules" modules -j8
  make ARCH=arm64 LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH="$PWD/out-modules" modules_install
)

tar xf r8125-9.012.04.tar.bz2

(
  cd r8125-9.012.04/src

  sed -i 's/ENABLE_MULTIPLE_TX_QUEUE = n/ENABLE_MULTIPLE_TX_QUEUE = y/' Makefile
  sed -i 's/ENABLE_RSS_SUPPORT = n/ENABLE_RSS_SUPPORT = y' Makefile
  sed -i 's/CONFIG_ASPM = y/CONFIG_ASPM = n/' Makefile

  cat Makefile
  sleep 10

  make LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 -C ~/kernel/ M=$(pwd) modules
  make LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 -C ~/kernel/ M=$(pwd) INSTALL_MOD_PATH="/root/kernel/out-modules" modules_install
)

git clone https://github.com/apernet/tcp-brutal --depth=1

(
  cd tcp-brutal

  make LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 -C ~/kernel/ M=$(pwd) modules
  make LLVM=1 LLVM_IAS=1 CROSS_COMPILE=aarch64-linux-gnu- ARCH=arm64 -C ~/kernel/ M=$(pwd) INSTALL_MOD_PATH="/root/kernel/out-modules" modules_install
)
