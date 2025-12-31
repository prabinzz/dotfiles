#!/bin/bash

echo "Installing base packages..."

PACKAGES=(
  hyprland
  hypridle
  sddm
  waybar
  rofi
  swww
  xdg-desktop-portal-hyprland
  kitty
  nautilus
  neovim
  ttf-jetbrains-mono-nerd
  noto-fonts-emoji
  polkit-gnome
  qt5-wayland
  qt6-wayland
  brightnessctl
  pamixer
  jq
  fzf
  swaync
  libnotify
  btop
  zed
  less
  slurp
  wtype
  grim
  wl-clipboard
  pavucontrol
  dnsmasq
  rustup
  blueman
  imagemagick
  satty
  github-cli
  starship
  unzip
  zoxide
)

sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

echo "Base packages installed."
