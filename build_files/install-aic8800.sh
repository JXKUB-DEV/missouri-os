#!/usr/bin/env bash

set -ouex pipefail

DRIVER_DIR="/tmp/aic8800d80"

dnf5 install -y \
  git \
  gcc \
  make \
  elfutils-libelf-devel \
  kernel-devel \
  kernel-headers

git clone --depth=1 \
  https://github.com/shenmintao/aic8800d80.git \
  "${DRIVER_DIR}"

cd "${DRIVER_DIR}/drivers/aic8800"

make
