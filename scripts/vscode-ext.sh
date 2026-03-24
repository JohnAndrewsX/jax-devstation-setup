#!/bin/bash
# vscode-ext.sh – Installs VSCode extensions and copies recommended settings

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

EXT_FILE="$PROJECT_DIR/config/vscode-extensions.txt"
SETTINGS_SOURCE="$PROJECT_DIR/config/vscode-settings.json"

install_extensions() {
  if ! command -v code &>/dev/null; then
    echo "WARNING: VSCode ('code') not in PATH. Skipping extensions." >&2
    echo "  If VSCode was exported via Distrobox, start a new shell."
    return 1
  fi

  if [ ! -f "$EXT_FILE" ]; then
    echo "WARNING: $EXT_FILE not found." >&2
    return 1
  fi

  echo "Installing VSCode extensions..."
  while IFS= read -r ext; do
    # Skip empty lines and comments
    [[ -z "$ext" || "$ext" == \#* ]] && continue
    echo "  -> $ext"
    code --install-extension "$ext" --force 2>/dev/null || echo "    WARNING: $ext could not be installed"
  done < "$EXT_FILE"
}

copy_settings() {
  if [ ! -f "$SETTINGS_SOURCE" ]; then
    echo "No recommended settings found, skipping."
    return
  fi

  local vscode_config="$HOME/.config/Code/User"
  local target="$vscode_config/settings.json"

  mkdir -p "$vscode_config"

  if [ -f "$target" ]; then
    echo "VSCode settings.json already exists: $target"
    echo "  Skipping (merge manually if needed)."
    echo "  Recommended settings: $SETTINGS_SOURCE"
    return
  fi

  echo "Copying recommended settings..."
  cp "$SETTINGS_SOURCE" "$target"
  echo "  -> $target"
}

# --- Main logic ---
echo "=== VSCode Extensions + Settings ==="

install_extensions
copy_settings

echo "VSCode setup complete."
echo ""
