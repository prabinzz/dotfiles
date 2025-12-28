#!/bin/bash

echo "Installing tmux..."
sudo pacman -S --noconfirm --needed tmux

echo "Installing TPM (Tmux Plugin Manager)..."
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

if [ ! -d "$TPM_DIR" ]; then
    echo "Cloning TPM into $TPM_DIR..."
    mkdir -p "$HOME/.config/tmux/plugins"
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "TPM already installed at $TPM_DIR"
fi

echo "Tmux installation and setup complete."
echo "Ensure you run scripts/07-copyconfigs.sh to apply the tmux configuration."
