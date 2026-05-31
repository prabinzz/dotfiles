#!/bin/bash

echo "Installing and configuring nbfc-linux..."

yay -S nbfc-linux --noconfirm --needed

if [ $? -ne 0 ]; then
  echo "Failed to install nbfc-linux."
  exit 1
fi

echo "Configuring nbfc-linux for Acer Predator G3-572..."
sudo nbfc config -s "Acer Predator G3-572"

echo "Starting nbfc-linux service..."
sudo nbfc start

if [ $? -eq 0 ]; then
  echo "nbfc-linux installed and configured successfully."
else
  echo "Failed to start nbfc-linux service."
fi
