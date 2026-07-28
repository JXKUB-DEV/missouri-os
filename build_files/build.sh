#!/usr/bin/env bash

set -ouex pipefail

# ---------------------------------------------------------
# Install required packages first
# ---------------------------------------------------------

dnf5 install -y \
  tmux \
  plymouth-plugin-script

# ---------------------------------------------------------
# Copy system files into the image
# ---------------------------------------------------------

cp -avf "/ctx/system_files"/. /

# ---------------------------------------------------------
# Missouri OS metadata
# ---------------------------------------------------------

set_os_release_value() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" /usr/lib/os-release; then
    sed -i "s|^${key}=.*|${key}=\"${value}\"|" /usr/lib/os-release
  else
    printf '%s="%s"\n' "${key}" "${value}" >> /usr/lib/os-release
  fi
}

set_os_release_value "NAME" "Missouri OS"
set_os_release_value "PRETTY_NAME" "Missouri OS"
set_os_release_value "LOGO" "missouri-os-logo"
set_os_release_value "DEFAULT_HOSTNAME" "missouri-os"
set_os_release_value "HOME_URL" "https://github.com/JXKUB-DEV/missouri-os"
set_os_release_value "DOCUMENTATION_URL" "https://github.com/JXKUB-DEV/missouri-os"
set_os_release_value "SUPPORT_URL" "https://github.com/JXKUB-DEV/missouri-os/issues"
set_os_release_value "BUG_REPORT_URL" "https://github.com/JXKUB-DEV/missouri-os/issues"

# ID and VARIANT_ID stay as bazzite for compatibility.

# ---------------------------------------------------------
# Missouri OS icons
# ---------------------------------------------------------

install -Dm644 \
  "/ctx/system_files/missouri-os-logo.png" \
  "/usr/share/pixmaps/missouri-os-logo.png"

install -Dm644 \
  "/ctx/system_files/missouri-os-logo.png" \
  "/usr/share/icons/hicolor/512x512/apps/missouri-os-logo.png"

gtk-update-icon-cache -f /usr/share/icons/hicolor || true

# ---------------------------------------------------------
# Missouri OS Plymouth theme
# ---------------------------------------------------------

install -Dm644 \
  "/ctx/system_files/missouri-os-plymouth-logo.png" \
  "/usr/share/plymouth/themes/missouri/missouri-logo.png"

install -Dm644 \
  "/ctx/system_files/missouri-os-plymouth-logo.png" \
  "/usr/share/plymouth/themes/missouri/spinner.png"

install -d /etc/plymouth

cat > /etc/plymouth/plymouthd.conf <<'EOF'
[Daemon]
Theme=missouri
ShowDelay=0
EOF

# Fail the build early if one of the theme files is missing
test -f /usr/share/plymouth/themes/missouri/missouri.plymouth
test -f /usr/share/plymouth/themes/missouri/missouri.script
test -f /usr/share/plymouth/themes/missouri/missouri-logo.png
test -f /usr/share/plymouth/themes/missouri/spinner.png

# ---------------------------------------------------------
# Missouri OS wallpaper
# ---------------------------------------------------------

install -Dm644 \
  "/ctx/system_files/missouri-os-wallpaper.png" \
  "/usr/share/wallpapers/MissouriOS/contents/images/3840x2160.png"

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
# Apply wallpaper once for every new user
# ---------------------------------------------------------

cat > /usr/bin/missouri-set-wallpaper <<'EOF'
#!/usr/bin/env bash

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

# ---------------------------------------------------------
# Remove temporary copies from filesystem root
# ---------------------------------------------------------

rm -f \
  /missouri-os-logo.png \
  /missouri-os-wallpaper.png \
  /missouri-os-plymouth-logo.png \
  /missouri-os-plymouth-logo-16bit.png

# ---------------------------------------------------------
# Enable services
# ---------------------------------------------------------

systemctl enable podman.socket
