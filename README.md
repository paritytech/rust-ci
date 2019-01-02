# rust-ci
WIP: New CI implementation

# How to crosscompile parity-eth for windows:
```
git clone https://github.com/paritytech/rust-ci.git
cd rust-ci
docker build -t crossy .
docker run -it --rm crossy 
```
inside the container:
```
export CARGO_HOME=$CARGO_HOME
export CARGO_TARGET=x86_64-pc-windows-gnu
export CI_SERVER_NAME="Gitlab CI"

git clone https://github.com/paritytech/libusb-sys.git
cd libusb-sys/
apt install nano
nano build.rs 
```
change this file according to: https://github.com/paritytech/libusb-sys/issues/5

patch Libusb:
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
proceed to Parity-Ethereum:
```
git clone https://github.com/paritytech/parity-ethereum.git
cd parity-ethereum
cargo update -p parity-rocksdb-sys
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
windows-cc troubles:
solved issue with rocksdb:
https://github.com/paritytech/rust-rocksdb/pull/27
and old dependencies:
https://github.com/paritytech/parity-ethereum/pull/10082

not-yet solved libusb issue:
https://github.com/paritytech/libusb-sys/issues/5
	here we wait for official lib to be fixed:
	https://github.com/libusb/libusb/pull/242

android-cc troubles:
solved:
https://github.com/paritytech/rust-snappy/pull/9
https://github.com/paritytech/rust-rocksdb/pull/25
and
https://github.com/paritytech/libusb-sys/pull/4 

now it seems like we are waiting for official libusb

maybe android will loose the libusb:
https://github.com/paritytech/parity-ethereum/issues/10058

but it will be supported in other places:
https://github.com/paritytech/parity-ethereum/pull/10055

- check if --locked works: not yet
https://github.com/paritytech/parity-ethereum/pull/10105/files

- manual:
https://github.com/paritytech/rust-ci/edit/master/README.md
