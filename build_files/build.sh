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

# Install Missouri OS wallpaper
install -Dm644 /ctx/system_files/missouri-os-wallpaper.png \
  /usr/share/wallpapers/MissouriOS/contents/images/3840x2160.png

# Wallpaper information for KDE
cat > /usr/share/wallpapers/MissouriOS/metadata.json <<'EOF'
{
  "KPlugin": {
    "Id": "MissouriOS",
    "Name": "Missouri OS",
    "Description": "Official Missouri OS wallpaper",
    "Authors": [
      {
        "Name": "JXKUB"
      }
    ]
  }
}
EOF

# Script that sets the wallpaper once for every user
install -d /usr/local/bin
cat > /usr/local/bin/missouri-set-wallpaper <<'EOF'
#!/bin/bash

MARKER="$HOME/.config/missouri-wallpaper-set"

if [ ! -f "$MARKER" ]; then
    if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
        plasma-apply-wallpaperimage \
          /usr/share/wallpapers/MissouriOS/contents/images/3840x2160.png
        mkdir -p "$HOME/.config"
        touch "$MARKER"
    fi
fi
EOF

chmod +x /usr/local/bin/missouri-set-wallpaper

# Run the wallpaper script automatically after login
install -d /etc/xdg/autostart
cat > /etc/xdg/autostart/missouri-wallpaper.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Missouri OS Wallpaper
Exec=/usr/local/bin/missouri-set-wallpaper
OnlyShowIn=KDE;
X-KDE-autostart-after=panel
NoDisplay=true
EOF


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
