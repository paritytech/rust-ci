FROM rust:stretch AS base
LABEL maintainer="Parity Technologies <devops@parity.io>"

# install tools and dependencies
RUN apt-get -y update && \
	apt-get install -y --no-install-recommends \
	software-properties-common curl git \
	make cmake ca-certificates g++ rhash \
	gcc pkg-config libudev-dev time

# removed:
# binutils binutils-dev snapcraft gettext file python build-essential zip dpkg-dev rpm libssl-dev openssl ruby-dev

#install nodejs and yarn
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
	apt-get -y update && apt-get install -y --no-install-recommends \
	nodejs yarn

RUN mkdir /parity-ethereum
WORKDIR /parity-ethereum

RUN cargo install cargo-audit sccache

# cleanup
RUN echo cleanup && \
	apt-get autoremove -y && \
	apt-get clean -y && \
	rm -rf /tmp/* /var/tmp/*

# show backtraces
ENV RUST_BACKTRACE 1

# compiler ENV
ENV CC gcc
ENV CXX g++
ENV CARGO_TARGET x86_64-unknown-linux-gnu
ENV CARGO_HOME /parity-ethereum/.cargo/
ENV RUSTC_WRAPPER sccache

# FIXME: change git policy to fetch
# RUN git clone https://github.com/paritytech/parity-ethereum.git .

VOLUME /parity-ethereum/target $CARGO_HOME

# windows compilation
# FROM base AS cross-windows

#RUN apt-get install -y --no-install-recommends mingw-w64
#RUN rustup target add x86_64-pc-windows-gnu

#new
#ENV CC_x86_64_pc_windows_gnu x86_64-w64-mingw32-gcc-posix
#ENV CXX_x86_64_pc_windows_gnu x86_64-w64-mingw32-g++-posix
#ENV AR_x86_64_pc_windows_gnu x86_64-w64-mingw32-gcc-ar

#RUN echo -e '\n[target.x86_64-pc-windows-gnu]\nlinker = "x86_64-w64-mingw32-gcc-posix"\n' >> parity-ethereum/.cargo/config

# TL;DR add the /wd 5045 flag when compiling with MSVC and it should solve this specific problem.
# ENV CL /wd5045

# Libusb
# ARG USB_VERSION=v1.0.22
# ARG USB_HASH=0034b2afdcdb1614e78edaa2a9e22d5936aeae5d
# RUN set -ex \
#     && git clone https://github.com/libusb/libusb.git -b ${USB_VERSION} \
#     && cd libusb \
#     && test `git rev-parse HEAD` = ${USB_HASH} || exit 1 \
#     && ./autogen.sh \
#     && CFLAGS="-fPIC" CXXFLAGS="-fPIC" ./configure --disable-shared \
#     && make \
# && make install

# darwin compilation
#FROM base AS cross-darwin

#RUN rustup target add x86_64-apple-darwin

# android compilation
#FROM base AS cross-android
