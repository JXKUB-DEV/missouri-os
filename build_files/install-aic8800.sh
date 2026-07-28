#!/usr/bin/env bash

set -ouex pipefail

DRIVER_DIR="/usr/src/aic8800d80"

dnf5 install -y \
  git \
  gcc \
  make \
  dkms \
  elfutils-libelf-devel \
  kernel-devel \
  kernel-headers

rm -rf "${DRIVER_DIR}"

git clone --depth=1 \
  https://github.com/shenmintao/aic8800d80.git \
  "${DRIVER_DIR}"

echo "AIC8800D80 DKMS source installed in ${DRIVER_DIR}"
