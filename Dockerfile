FROM ubuntu:noble

RUN apt update
RUN apt upgrade -y
RUN apt install -y build-essential clang llvm lld sudo wget unzip
RUN wget https://raw.githubusercontent.com/friendlyarm/build-env-on-ubuntu-bionic/master/install.sh
RUN chmod +x install.sh
RUN ./install.sh

RUN wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/HEAD/clang-r522817.tar.gz
RUN mkdir /opt/android-clang
RUN tar xf clang-r522817.tar.gz -C /opt/android-clang

RUN wget https://dl.google.com/android/repository/android-ndk-r26d-linux.zip
RUN (cd /opt; unzip $PWD/android-ndk-r26d-linux.zip)

ENV PATH=/opt/android-clang/bin:/opt/FriendlyARM/toolchain/11.3-aarch64/bin:$PATH
CMD ["/bin/su", "-l", "root"]
