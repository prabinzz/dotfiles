SCRIPT_DIR=$1
if [ -d "$SCRIPT_DIR/assets/.config" ]; then
  mkdir -p "$HOME/.config"
  echo "Copying configs to $HOME/.config/"
  cp -r "$SCRIPT_DIR/assets/.config/." "$HOME/.config/"
fi
if [ -d "$SCRIPT_DIR/assets/home/" ]; then
  echo "Copying home directory files to $HOME/"
  cp -r "$SCRIPT_DIR/assets/home/"{.,}* "$HOME/" 2>/dev/null
fi
if [ -d "$SCRIPT_DIR/assets/.local/" ]; then
  mkdir -p "$HOME/.local"
  echo "Copying user data to $HOME/.local/"
  cp -r "$SCRIPT_DIR/assets/.local/." "$HOME/.local/"
fi
