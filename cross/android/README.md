# WIP cross-compilation build for Android
export CARGO_HOME=$CARGO_HOME
export CARGO_TARGET=armv7-linux-androideabi
export CI_SERVER_NAME="Gitlab CI"

git clone https://github.com/paritytech/parity-ethereum.git
cd parity-ethereum
git checkout new_rust_ci
./scripts/gitlab/build-unix.sh