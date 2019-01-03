# WIP: New CI implementation

## How to crosscompile parity-eth for windows:
1. build and run docker container
```
git clone https://github.com/paritytech/rust-ci.git
cd rust-ci
docker build -t crossy .
docker run -it --rm crossy 
```
2. inside the container:
```
export CARGO_HOME=$CARGO_HOME
export CARGO_TARGET=x86_64-pc-windows-gnu
export CI_SERVER_NAME="Gitlab CI"
```
3. patch Libusb:

```
git clone https://github.com/paritytech/libusb-sys.git
cd libusb-sys/
apt install nano
nano build.rs 
```
change this file according to: https://github.com/paritytech/libusb-sys/issues/5

```
nano libusb/libusb/libusbi.h
```
change this line: 

`#if (defined(OS_WINDOWS) || defined(OS_WINCE)) && !defined(__GNUC__)`

to 

`#if (defined(OS_WINDOWS) || defined(OS_WINCE))`
```
cargo build --release --target x86_64-pc-windows-gnu
cd /build
```
4. proceed to Parity-Ethereum:
```
git clone https://github.com/paritytech/parity-ethereum.git
cd parity-ethereum
nano Cargo.toml
```
this should be inserted into `Cargo.toml`:
```
[patch."https://github.com/paritytech/libusb-sys"]
libusb-sys = { path = "/build/libusb-sys" }
```
```
nano .cargo/config
```
and this goes to `.cargo/config`:
```
[target.x86_64-pc-windows-gnu]
linker = "x86_64-w64-mingw32-gcc-posix"
```
proceed with build:
```
time cargo build --target $CARGO_TARGET --release --features final
# --locked flag doesn't work for now

```
# Notes
## windows-cc troubles:
issues with rocksdb:
- [x] https://github.com/paritytech/rust-rocksdb/pull/27

and old dependencies:
- [x] https://github.com/paritytech/parity-ethereum/pull/10082
- [x] https://github.com/paritytech/parity-ethereum/pull/10124

- [ ] libusb issue:
- https://github.com/paritytech/libusb-sys/issues/5

- [ ] now we wait for official lib to be fixed:
- https://github.com/libusb/libusb/pull/242

## android-cc troubles:
- [x] https://github.com/paritytech/rust-snappy/pull/9
- [x] https://github.com/paritytech/rust-rocksdb/pull/25
- [x] https://github.com/paritytech/libusb-sys/pull/4 

- [ ] now we wait for official libusb

- [ ] maybe android will loose the libusb:
- https://github.com/paritytech/parity-ethereum/issues/10058

- [ ] but it will be supported in other places:
- https://github.com/paritytech/parity-ethereum/pull/10055

- [ ] --locked
- https://github.com/paritytech/parity-ethereum/pull/10105/files

- [x] manual:
- https://github.com/paritytech/rust-ci/edit/master/README.md
