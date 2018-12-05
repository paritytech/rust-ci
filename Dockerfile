FROM rust:stretch AS base
LABEL maintainer="Parity Technologies <devops@parity.io>"

WORKDIR /build

# install tools and dependencies
RUN apt-get -y update
RUN apt-get install -y --no-install-recommends \
	software-properties-common curl git \
	make cmake ca-certificates g++ rhash \
  	gcc pkg-config libudev-dev time

# removed:
# binutils binutils-dev snapcraft gettext file python build-essential zip dpkg-dev rpm libssl-dev openssl ruby-dev


RUN cargo install cargo-audit

# show backtraces
ENV RUST_BACKTRACE 1

# cleanup
RUN echo cleanup
RUN apt-get autoremove -y
RUN apt-get clean -y
RUN rm -rf /tmp/* /var/tmp/*

# compiler ENV
ENV CC gcc
ENV CXX g++


FROM base AS crosscompile

# windows compilation
RUN apt-get install -y --no-install-recommends mingw-w64
RUN rustup target add x86_64-pc-windows-gnu

ENV CC_x86_64_pc_windows_gnu x86_64-w64-mingw32-gcc
ENV CXX_x86_64_pc_windows_gnu x86_64-w64-mingw32-g++
ENV AR_x86_64_pc_windows_gnu x86_64-w64-mingw32-ar
# TL;DR add the /wd 5045 flag when compiling with MSVC and it should solve this specific problem.
# ENV CL /wd5045

# Libusb
ARG USB_VERSION=v1.0.22
ARG USB_HASH=0034b2afdcdb1614e78edaa2a9e22d5936aeae5d
RUN set -ex \
    && git clone https://github.com/libusb/libusb.git -b ${USB_VERSION} \
    && cd libusb \
    # && test `git rev-parse HEAD` = ${USB_HASH} || exit 1 \
    && ./autogen.sh \
    && CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --disable-shared \
    && make \
&& make install

# darwin compilation
RUN rustup target add x86_64-apple-darwin
