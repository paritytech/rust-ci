FROM ubuntu:xenial
MAINTAINER Parity Technologies <devops@parity.io>

WORKDIR /build

# install tools and dependencies
RUN apt -y update && \
  apt install -y --no-install-recommends \
	software-properties-common curl git \
	make cmake ca-certificates g++ rhash \
    gcc pkg-config libudev-dev

# removed:
# binutils binutils-dev snapcraft gettext file python build-essential time zip dpkg-dev rpm libssl-dev openssl ruby-dev

# install rustup
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# rustup directory
ENV PATH /root/.cargo/bin:$PATH

# setup rust beta and nightly channel's
# discuss:
# RUN rustup install beta
# RUN rustup install nightly

# show backtraces
ENV RUST_BACKTRACE 1

# cleanup
RUN apt autoremove -y
RUN apt clean -y
RUN rm -rf /tmp/* /var/tmp/*

# compiler ENV
ENV CC gcc
ENV CXX g++