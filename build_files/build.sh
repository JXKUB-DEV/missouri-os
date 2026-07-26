#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /
# Missouri OS branding
sed -i 's/^NAME=.*/NAME="Missouri OS"/' /usr/lib/os-release
sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="Missouri OS"/' /usr/lib/os-release

# Install Missouri OS branding logo
install -Dm644 /ctx/system_files/missouri-os-logo.png \
  /usr/share/pixmaps/missouri-os-logo.png

# Tell desktop tools which distribution logo to use
if grep -q '^LOGO=' /usr/lib/os-release; then
  sed -i 's/^LOGO=.*/LOGO=missouri-os-logo/' /usr/lib/os-release
else
  echo 'LOGO=missouri-os-logo' >> /usr/lib/os-release
fi


### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
