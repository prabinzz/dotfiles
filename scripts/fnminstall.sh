#!/bin/zsh

# --- 1. System Update and Toolchain Installation (Pacman) ---
echo "Updating system packages and installing rustup..."
# Install the essential build tools (if not already present)
sudo pacman -Syu --needed base-devel --noconfirm

# Install rustup and set the default stable toolchain
sudo pacman -S --needed rustup --noconfirm

# The pacman rustup package doesn't automatically install a toolchain.
# The user needs to explicitly set one. We also need to source cargo's path.
# This part assumes ~/.cargo/bin is not yet in $PATH.
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
else
  # Install the stable toolchain and configure the environment variables
  # This step is crucial for `cargo install` to work immediately.
  rustup default stable
  echo "Sourcing cargo environment setup..."
  source "$HOME/.cargo/env"
fi

# --- 2. Install FNM (Fast Node Manager) via Cargo ---
echo "Installing fnm (Fast Node Manager) via cargo..."
if ! command -v cargo &>/dev/null; then
  echo "Error: cargo not found after rustup setup. Cannot proceed with fnm installation."
  return 1
fi
cargo install fnm

# --- 3. Run fnm Environment Setup for Current Session ---
# Since you don't want to modify ~/.zshrc, we must run the fnm env command
# and evaluate its output to temporarily update the PATH in this shell session.
echo "Setting up fnm environment for the current shell session..."
if ! command -v fnm &>/dev/null; then
  # fnm should be in ~/.cargo/bin, which is now sourced, but check again.
  echo "Error: fnm not found. Aborting Node installation."
  return 1
fi
eval "$(fnm env)"

# --- 4. Install and Configure Latest LTS Node.js Version ---
echo "Installing the latest LTS Node.js version with fnm..."
fnm install --lts

echo "Setting the installed LTS version as active for this session..."
fnm use --lts

echo "Setting the LTS version as the global default for future fnm sessions..."
fnm default --lts

# --- 5. Final Verification ---
echo "---"
echo "✅ Installation and configuration complete."
echo "Current Node Version:"
node -v
echo "Current npm Version:"
npm -v
