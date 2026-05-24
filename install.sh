#!/bin/bash

set -euo pipefail

# --- Help Function ---
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -a, --ask                Prompt before executing each selected installation script."
  echo "  -c, --sync-configs       Only sync configuration files."
  echo "  -s, --select             Select which scripts to run from a TUI checklist."
  echo "  -h, --help               Show this help message."
  echo ""
  echo "Default behavior (no options): Installs base/AUR/Flatpak packages and syncs configs."
}

# --- Argument Parsing ---
ask_before_exec=false
sync_only=false
select_mode=false

while [ "$#" -gt 0 ]; do
  case "$1" in
  -h | --help)
    show_help
    exit 0
    ;;
  -a | --ask)
    ask_before_exec=true
    ;;
  -c | --sync-configs)
    sync_only=true
    ;;
  -s | --select)
    select_mode=true
    ;;
  *)
    echo "Unknown option: $1" >&2
    show_help
    exit 1
    ;;
  esac
  shift
done

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$BASE_DIR/scripts"
CONFIG_SCRIPT="07-copyconfigs.sh"

if [ ! -d "$SCRIPTS_DIR" ]; then
  echo "Scripts directory not found: $SCRIPTS_DIR" >&2
  exit 1
fi

# Function to run a script
run_script() {
  local script_name="$1"
  local script_path="$SCRIPTS_DIR/$script_name"

  if [ -f "$script_path" ]; then
    if [ "$ask_before_exec" = true ]; then
      read -r -n 1 -p "--- Run script $script_name? (y/n): " REPLY
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "--- Skipping $script_name ---"
        echo ""
        return
      fi
    fi
    echo "--- Running $script_name ---"
    bash "$script_path" "$BASE_DIR"
    echo "--- Finished $script_name ---"
    echo ""
  else
    echo "--- Warning: Script $script_name not found. Skipping. ---"
    echo ""
  fi
}

get_install_scripts() {
  find "$SCRIPTS_DIR" -maxdepth 1 -type f -name "[0-9]*.sh" ! -name "$CONFIG_SCRIPT" -printf "%f\n" | sort
}

select_scripts_tui() {
  local all_scripts=("$@")
  SELECTED_SCRIPTS=()

  if [ "${#all_scripts[@]}" -eq 0 ]; then
    return 0
  fi

  if command -v whiptail >/dev/null 2>&1; then
    local options=()
    local script
    for script in "${all_scripts[@]}"; do
      options+=("$script" "" "OFF")
    done

    mapfile -t SELECTED_SCRIPTS < <(whiptail \
      --title "Dotfiles installer" \
      --separate-output \
      --checklist "Select scripts to run. Config sync runs last automatically." \
      22 78 14 \
      "${options[@]}" \
      3>&1 1>&2 2>&3) || return 1
  elif command -v dialog >/dev/null 2>&1; then
    local options=()
    local script
    for script in "${all_scripts[@]}"; do
      options+=("$script" "" "off")
    done

    mapfile -t SELECTED_SCRIPTS < <(dialog \
      --stdout \
      --title "Dotfiles installer" \
      --separate-output \
      --checklist "Select scripts to run. Config sync runs last automatically." \
      22 78 14 \
      "${options[@]}") || return 1
  else
    echo "No whiptail/dialog found; falling back to shell selection."
    echo "Install one of these for a real TUI checklist: sudo pacman -S libnewt dialog"
    echo ""
    echo "Select scripts to run (numbers separated by spaces, 'a' for all, 'q' to cancel):"

    local i=1
    local script
    for script in "${all_scripts[@]}"; do
      echo "$i) $script"
      ((i++))
    done

    echo ""
    read -r -p "Selections: " user_input

    if [[ "$user_input" == "a" ]]; then
      SELECTED_SCRIPTS=("${all_scripts[@]}")
    elif [[ "$user_input" != "q" ]]; then
      local num idx
      for num in $user_input; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#all_scripts[@]}" ]; then
          idx=$((num - 1))
          SELECTED_SCRIPTS+=("${all_scripts[$idx]}")
        else
          echo "Ignoring invalid selection: $num"
        fi
      done
    fi
  fi
}

run_selected_scripts() {
  mapfile -t ALL_SCRIPTS < <(get_install_scripts)

  if ! select_scripts_tui "${ALL_SCRIPTS[@]}"; then
    echo "Selection cancelled."
    return 0
  fi

  if [ "${#SELECTED_SCRIPTS[@]}" -eq 0 ]; then
    echo "No install scripts selected."
  else
    echo "Selected scripts: ${SELECTED_SCRIPTS[*]}"
    echo ""
    local script
    for script in "${SELECTED_SCRIPTS[@]}"; do
      run_script "$script"
    done
  fi

  # Always run config sync last in select mode.
  run_script "$CONFIG_SCRIPT"
}

echo "Starting installation..."
echo "======================"
echo ""

if [ "$sync_only" = true ]; then
  run_script "$CONFIG_SCRIPT"
elif [ "$select_mode" = true ]; then
  run_selected_scripts
else
  # Default behavior: Base Packages + AUR Packages + Flatpak Packages + Config Sync
  echo "Running default installation: Base Packages, AUR Packages, Flatpak Packages, and Config Sync."

  run_script "01-base-packages.sh"
  run_script "02-aur-packages.sh"
  run_script "03-flatpak-packages.sh"
  run_script "17-fix-portals.sh"

  # Always run config sync last.
  run_script "$CONFIG_SCRIPT"
fi

echo "======================"
echo "Installation complete!"
