FROM ubuntu:jammy

RUN apt update
RUN apt upgrade -y
RUN apt install -y build-essential clang llvm lld sudo wget
RUN wget https://raw.githubusercontent.com/friendlyarm/build-env-on-ubuntu-bionic/master/install.sh
RUN chmod +x install.sh
RUN ./install.sh

RUN wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/64f8359e67f94b088bcd428570a59d14213c51cc/clang-r510928.tar.gz
RUN mkdir /opt/android-clang
RUN tar xf clang-r510928.tar.gz -C /opt/android-clang

ENV PATH=/opt/android-clang/bin:/opt/FriendlyARM/toolchain/11.3-aarch64/bin:$PATH
ENV ARCH=arm64
ENV CROSS_COMPILE=aarch64-linux-gnu-

CMD ["/bin/su", "-l", "root"]
