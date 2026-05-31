#!/bin/bash

echo "Starting copy configs..."

SCRIPT_DIR=$1
if [ -z "$SCRIPT_DIR" ]; then
  SCRIPT_DIR=$(dirname "$0")/..
fi

if [ -d "$SCRIPT_DIR/configs/config" ]; then
  mkdir -p "$HOME/.config"
  echo "Copying configs to $HOME/.config/..."
  cp -r "$SCRIPT_DIR/configs/config/." "$HOME/.config/"
fi
if [ -d "$SCRIPT_DIR/configs/home/" ]; then
  echo "Copying home directory files to $HOME/..."
  cp -r "$SCRIPT_DIR/configs/home/"{.,}* "$HOME/" 2>/dev/null
fi
if [ -d "$SCRIPT_DIR/configs/local/" ]; then
  mkdir -p "$HOME/.local"
  echo "Copying user data to $HOME/.local/..."
  cp -r "$SCRIPT_DIR/configs/local/." "$HOME/.local/"
fi

echo "Copy configs finished successfully."
