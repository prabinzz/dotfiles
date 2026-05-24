#!/bin/bash

set -euo pipefail

echo "Installing Flatpak support..."

sudo pacman -S --noconfirm --needed flatpak

# Flathub is where the package IDs below are resolved from. Flatpak will also
# install any required runtimes/extensions for these apps automatically.
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

PACKAGES=(
  it.mijorus.gearlever
)

if [ "${#PACKAGES[@]}" -eq 0 ]; then
  echo "No Flatpak packages configured."
  exit 0
fi

echo "Installing Flatpak packages from Flathub: ${PACKAGES[*]}"
sudo flatpak install --system --assumeyes --or-update flathub "${PACKAGES[@]}"

echo "Flatpak packages installed."
