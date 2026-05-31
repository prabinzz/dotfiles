#!/bin/bash

echo "Installing base packages..."

PACKAGES=(
  hypridle
  sddm
  rofi
  awww
  xdg-desktop-portal-hyprland
  niri
  xdg-desktop-portal-kde
  xdg-desktop-portal-gnome
  xdg-desktop-portal-gtk
  xdg-desktop-portal-wlr
  pipewire
  pipewire-pulse
  pipewire-alsa
  wireplumber
  gst-plugin-pipewire
  kitty
  dolphin
  plasma-integration
  breeze
  kio-extras
  archlinux-xdg-menu
  desktop-file-utils
  shared-mime-info
  neovim
  ttf-jetbrains-mono-nerd
  noto-fonts-emoji
  polkit-gnome
  qt5-wayland
  qt6-wayland
  qt5ct
  qt6ct
  brightnessctl
  pamixer
  playerctl
  jq
  fzf
  swaync
  libnotify
  btop
  zed
  less
  slurp
  wtype
  wl-clipboard
  wl-mirror
  pavucontrol
  dnsmasq
  rustup
  blueman
  imagemagick
  satty
  github-cli
  starship
  unzip
  unrar
  zoxide
  rclone
  conky
  network-manager-applet
  wlogout
)

sudo pacman -S --noconfirm --needed "${PACKAGES[@]}"

echo "Base packages installed."
