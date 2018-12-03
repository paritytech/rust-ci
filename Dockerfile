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

ENV CC_x86_64_pc_windows_gnu i686-w64-mingw32-gcc
ENV CXX_x86_64_pc_windows_gnu i686-w64-mingw32-g++
ENV AR_x86_64_pc_windows_gnu i686-w64-mingw32-ar

# darwin compilation
RUN rustup target add x86_64-apple-darwin
