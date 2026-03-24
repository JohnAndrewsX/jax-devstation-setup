#!/bin/bash
# distrobox.sh – Creates dev container and exports VSCode
# Primary for Atomic systems (Silverblue, Bazzite).
# On Traditional/Arch: installs VSCode directly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/detect-os.sh"

CONTAINER_NAME="dev"
# Update version as needed
CONTAINER_IMAGE="registry.fedoraproject.org/fedora:43"

install_distrobox() {
  if command -v distrobox &>/dev/null; then
    echo "Distrobox already installed."
    return
  fi

  echo "Installing Distrobox..."
  curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
  export PATH="$HOME/.local/bin:$PATH"
}

create_container() {
  if distrobox list 2>/dev/null | grep -q "$CONTAINER_NAME"; then
    echo "Container '$CONTAINER_NAME' already exists."
    return
  fi

  echo "Creating container '$CONTAINER_NAME' (image: $CONTAINER_IMAGE)..."
  distrobox create --name "$CONTAINER_NAME" --image "$CONTAINER_IMAGE" --yes
}

install_vscode_in_container() {
  echo "Installing VSCode + build tools in container..."
  distrobox enter "$CONTAINER_NAME" -- bash -c '
    # Add Microsoft repo if needed
    if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
      sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
      echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    fi

    sudo dnf install -y code gcc gcc-c++ make git 2>/dev/null
  '

  echo "Exporting VSCode to host menu..."
  distrobox enter "$CONTAINER_NAME" -- distrobox-export --app code 2>/dev/null || true
}

install_vscode_native_arch() {
  if command -v code &>/dev/null; then
    echo "VSCode already installed."
    return
  fi

  echo "Installing VSCode via pacman/AUR..."
  if command -v yay &>/dev/null; then
    yay -S --noconfirm visual-studio-code-bin
  elif command -v paru &>/dev/null; then
    paru -S --noconfirm visual-studio-code-bin
  else
    echo "WARNING: No AUR helper (yay/paru) found. Please install VSCode manually."
    return 1
  fi
}

install_vscode_native_apt() {
  if command -v code &>/dev/null; then
    echo "VSCode already installed."
    return
  fi

  echo "Installing VSCode via apt..."
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/ms.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
  sudo apt update && sudo apt install -y code
}

install_vscode_native_dnf() {
  if command -v code &>/dev/null; then
    echo "VSCode already installed."
    return
  fi

  echo "Installing VSCode via dnf..."
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
  sudo dnf install -y code
}

# --- Main logic ---
echo "=== VSCode Installation ==="

case "$OS_TYPE" in
  atomic)
    install_distrobox
    create_container
    install_vscode_in_container
    ;;
  arch)
    install_vscode_native_arch
    ;;
  traditional)
    case "$PKG_MANAGER" in
      apt) install_vscode_native_apt ;;
      dnf) install_vscode_native_dnf ;;
    esac
    ;;
  *)
    echo "ERROR: OS type '$OS_TYPE' not supported." >&2
    exit 1
    ;;
esac

echo "VSCode installation complete."
