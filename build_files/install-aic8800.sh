#!/usr/bin/env bash

set -ouex pipefail

DRIVER_NAME="aic8800"
DRIVER_VERSION="1.0.0"
DRIVER_DIR="/usr/src/${DRIVER_NAME}-${DRIVER_VERSION}"
INSTALLER="/usr/libexec/missouri-install-aic8800"

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

install -d /usr/lib/firmware
cp -a "${DRIVER_DIR}/fw/." /usr/lib/firmware/

install -d /usr/libexec

cat > "${INSTALLER}" <<'EOF'
#!/usr/bin/env bash

set -euxo pipefail

DRIVER_NAME="aic8800"
DRIVER_VERSION="1.0.0"
DRIVER_DIR="/usr/src/${DRIVER_NAME}-${DRIVER_VERSION}"
KERNEL_VERSION="$(uname -r)"

if dkms status | grep -q "${DRIVER_NAME}/${DRIVER_VERSION}.*${KERNEL_VERSION}.*installed"; then
  modprobe aic_load_fw || true
  modprobe aic8800_fdrv || true
  exit 0
fi

dkms remove "${DRIVER_NAME}/${DRIVER_VERSION}" --all || true
dkms add "${DRIVER_DIR}"
dkms build "${DRIVER_NAME}/${DRIVER_VERSION}" -k "${KERNEL_VERSION}"
dkms install "${DRIVER_NAME}/${DRIVER_VERSION}" -k "${KERNEL_VERSION}"

depmod -a "${KERNEL_VERSION}"

modprobe aic_load_fw
modprobe aic8800_fdrv
EOF

chmod 0755 "${INSTALLER}"

cat > /usr/lib/systemd/system/missouri-aic8800-install.service <<'EOF'
[Unit]
Description=Install Missouri OS AIC8800 Wi-Fi driver
After=local-fs.target
ConditionPathExists=/usr/src/aic8800-1.0.0/dkms.conf

[Service]
Type=oneshot
ExecStart=/usr/libexec/missouri-install-aic8800
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable missouri-aic8800-install.service
