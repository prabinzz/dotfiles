#!/bin/bash

echo "Installing gemini-cli..."

if ! command -v bun &>/dev/null; then
  echo "Error: bun is not installed. Please run 11-fnminstall.sh or install bun first."
  exit 1
fi

bun install --global @google/gemini-cli

if [ $? -eq 0 ]; then
  echo "gemini-cli installed successfully."
else
  echo "Failed to install gemini-cli."
  exit 1
fi
