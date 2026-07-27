#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ into the image
cp -avf "/ctx/system_files"/. /

# ---------------------------------------------------------
# Missouri OS branding
# ---------------------------------------------------------

sed -i 's/^NAME=.*/NAME="Missouri OS"/' /usr/lib/os-release
sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="Missouri OS"/' /usr/lib/os-release

# Install Missouri OS distribution logo
install -Dm644 \
  "/ctx/system_files/missouri-os-logo.png" \
  "/usr/share/pixmaps/missouri-os-logo.png"

# Tell desktop programs which distribution logo to use
if grep -q '^LOGO=' /usr/lib/os-release; then
  sed -i 's/^LOGO=.*/LOGO=missouri-os-logo/' /usr/lib/os-release
else
  echo 'LOGO=missouri-os-logo' >> /usr/lib/os-release
fi

# ---------------------------------------------------------
# Missouri OS wallpaper
# ---------------------------------------------------------

install -Dm644 \
  "/ctx/system_files/missouri-os-wallpaper.png" \
  "/usr/share/wallpapers/MissouriOS/contents/images/3840x2160.png"

# Wallpaper information shown in KDE
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

# ---------------------------------------------------------
# Set wallpaper once when a user first logs in
# ---------------------------------------------------------

cat > /usr/bin/missouri-set-wallpaper <<'EOF'
#!/bin/bash

MARKER="${HOME}/.config/missouri-wallpaper-set"
WALLPAPER="/usr/share/wallpapers/MissouriOS/contents/images/3840x2160.png"

if [[ ! -f "${MARKER}" ]]; then
  if command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
    plasma-apply-wallpaperimage "${WALLPAPER}"

    mkdir -p "${HOME}/.config"
    touch "${MARKER}"
  fi
fi
EOF

chmod 0755 /usr/bin/missouri-set-wallpaper

# Start the wallpaper script automatically after KDE login
install -d /etc/xdg/autostart

cat > /etc/xdg/autostart/missouri-wallpaper.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Missouri OS Wallpaper
Exec=/usr/bin/missouri-set-wallpaper
OnlyShowIn=KDE;
X-KDE-autostart-after=panel
NoDisplay=true
EOF

# Remove the temporary asset copies from the filesystem root
rm -f /missouri-os-logo.png
rm -f /missouri-os-wallpaper.png

# ---------------------------------------------------------
# Packages from the original image template
# ---------------------------------------------------------

dnf5 install -y tmux

# Enable Podman socket
systemctl enable podman.socket
