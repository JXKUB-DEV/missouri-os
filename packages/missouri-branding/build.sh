#!/usr/bin/env bash
set -oue pipefail

mkdir -p /usr/share/pixmaps
mkdir -p /usr/share/wallpapers/MissouriOS/contents/images

install -Dm644 \
  /ctx/system_files/missouri-os-logo.png \
  /usr/share/pixmaps/missouri-os-logo.png

install -Dm644 \
  /ctx/system_files/missouri-os-wallpaper.png \
  /usr/share/wallpapers/MissouriOS/contents/images/3840x2160.png
