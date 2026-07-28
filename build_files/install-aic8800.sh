#!/usr/bin/env bash

set -ouex pipefail

DRIVER_DIR="/usr/src/aic8800-1.0.0"

dnf5 install -y \
  git \
  gcc \
  make \
  dkms \
  elfutils-libelf-devel \
  kernel-devel \
  kernel-headers \
  usb_modeswitch \
  eject

rm -rf "${DRIVER_DIR}"

git clone --depth=1 \
  https://github.com/shenmintao/aic8800d80.git \
  "${DRIVER_DIR}"

install -Dm644 \
  "${DRIVER_DIR}/aic.rules" \
  /usr/lib/udev/rules.d/80-aic8800.rules

cp -a "${DRIVER_DIR}/fw/." /usr/lib/firmware/

cat > /usr/lib/systemd/system/missouri-aic8800-install.service <<'EOF'
[Unit]
Description=Install Missouri OS AIC8800 Wi-Fi driver
After=local-fs.target
ConditionPathExists=!/var/lib/missouri-aic8800-installed

[Service]
Type=oneshot
ExecStart=/usr/bin/bash /usr/src/aic8800-1.0.0/install.sh
ExecStartPost=/usr/bin/touch /var/lib/missouri-aic8800-installed
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable missouri-aic8800-install.service

echo "AIC8800 DKMS first-boot installer prepared."
