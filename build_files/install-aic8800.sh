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

KERNEL_BUILD_DIR="$(find /usr/lib/modules -mindepth 2 -maxdepth 2 -type d -name build | head -n 1)"
KERNEL_VERSION="$(basename "$(dirname "${KERNEL_BUILD_DIR}")")"

if [[ -z "${KERNEL_BUILD_DIR}" || ! -d "${KERNEL_BUILD_DIR}" ]]; then
  echo "Keine Kernel-Build-Dateien im Missouri-Image gefunden."
  exit 1
fi

echo "Baue AIC8800D80 für Kernel ${KERNEL_VERSION}"
echo "Kernel-Build-Verzeichnis: ${KERNEL_BUILD_DIR}"

cd "${DRIVER_DIR}/drivers/aic8800"

make \
  KVER="${KERNEL_VERSION}" \
  KDIR="${KERNEL_BUILD_DIR}"

make \
  KVER="${KERNEL_VERSION}" \
  KDIR="${KERNEL_BUILD_DIR}" \
  install
