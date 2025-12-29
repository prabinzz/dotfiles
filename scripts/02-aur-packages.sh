#!/bin/bash

echo "Installing AUR packages..."

# Check for yay
if ! command -v yay &>/dev/null; then
  echo "yay is not installed. Installing it."
  git clone https://aur.archlinux.org/yay.git ~/yay
  cd ~/yay
  makepkg -si
  rm -rf ~/yay
fi

AURPACKAGES=(
  google-chrome
  linux-wifi-hotspot
  nwg-look
  nwg-displays
  bun-bin
  rofi-greenclip
  rofi-emoji
)

yay -S --noconfirm --needed "${AURPACKAGES[@]}"

echo "AUR packages installed."
