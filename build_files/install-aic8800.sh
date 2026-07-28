#!/usr/bin/env bash

set -ouex pipefail

DRIVER_DIR="/tmp/aic8800d80"

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

chmod +x "${DRIVER_DIR}/install.sh"

cp -a "${DRIVER_DIR}" /usr/src/aic8800-1.0.0

echo "AIC8800 DKMS sources prepared."
