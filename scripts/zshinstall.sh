#!/bin/bash

# --- 1. Install Zsh and Dependencies (Git, Curl) using pacman ---

echo "Installing Zsh, Git, and Curl via pacman..."

# The '-S --noconfirm' option installs packages without prompting for confirmation
sudo pacman -S --noconfirm zsh git curl

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to install packages. Check your internet connection and pacman mirrors."
  exit 1
fi

echo "Zsh, Git, and Curl installed successfully."
echo "---"

# --- 2. Change Default Shell to Zsh ---

echo "Changing default shell to Zsh. You may be prompted for your password."
# The 'chsh' command changes the user login shell
chsh -s $(which zsh)

if [ $? -eq 0 ]; then
  echo "Default shell changed to Zsh."
else
  echo "Failed to change default shell. Please ensure /usr/bin/zsh is listed in /etc/shells."
fi

echo "---"

# --- 3. Install Oh My Zsh (Optional but highly recommended) ---
# Oh My Zsh simplifies Zsh configuration and provides themes and plugins.

echo "Installing Oh My Zsh..."

# Check if Oh My Zsh is already installed
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh is already installed."
else
  # Install via curl, using the --unattended flag to prevent chsh prompt duplication
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  if [ $? -eq 0 ]; then
    echo "Oh My Zsh installed successfully! Your ~/.zshrc file has been created."
  else
    echo "Failed to install Oh My Zsh."
  fi
fi

echo "---"
echo "✅ Zsh and Oh My Zsh setup complete on Arch Linux!"
echo "Please **log out and log back in** (or simply type 'zsh') for the changes to take effect and to start using Zsh."
