#!/bin/bash
# distrobox.sh – Creates dev container and exports VSCode
# Primary for Atomic systems (Silverblue, Bazzite).
# On Traditional/Arch: installs VSCode directly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/detect-os.sh"

CONTAINER_NAME="dev"
CONTAINER_IMAGE="registry.fedoraproject.org/fedora-toolbox:latest"
IMAGE_PRESET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --container-name)
      CONTAINER_NAME="$2"
      shift
      ;;
    --container-image)
      CONTAINER_IMAGE="$2"
      IMAGE_PRESET=true
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
  shift
done

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

pick_image() {
  local default_image="$CONTAINER_IMAGE"
  local -a images=(
    "registry.fedoraproject.org/fedora-toolbox:latest"
    "registry.fedoraproject.org/fedora:latest"
    "docker.io/library/ubuntu:24.04"
    "docker.io/library/alpine:latest"
  )

  # Add local images from podman/docker, deduplicating
  local engine=""
  if command -v podman &>/dev/null; then
    engine="podman"
  elif command -v docker &>/dev/null; then
    engine="docker"
  fi

  if [[ -n "$engine" ]]; then
    while IFS= read -r img; do
      [[ -z "$img" ]] && continue
      local dup=false
      for existing in "${images[@]}"; do
        if [[ "$existing" == "$img" ]]; then
          dup=true
          break
        fi
      done
      if [[ "$dup" == false ]]; then
        images+=("$img")
      fi
    done < <("$engine" images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -v '<none>')
  fi

  echo ""
  echo "Select container image:"
  local i
  for i in "${!images[@]}"; do
    if [[ "${images[$i]}" == "$default_image" ]]; then
      printf "  %d) %s  (default)\n" "$((i+1))" "${images[$i]}"
    else
      printf "  %d) %s\n" "$((i+1))" "${images[$i]}"
    fi
  done
  printf "  %d) Enter custom image\n" "$(( ${#images[@]} + 1 ))"
  echo ""

  local choice
  read -rp "Choice [1]: " choice

  if [[ -z "$choice" ]]; then
    CONTAINER_IMAGE="$default_image"
  elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#images[@]} )); then
    CONTAINER_IMAGE="${images[$((choice-1))]}"
  elif [[ "$choice" =~ ^[0-9]+$ ]] && (( choice == ${#images[@]} + 1 )); then
    local custom_image
    read -rp "Enter image (e.g. docker.io/library/debian:latest): " custom_image
    if [[ -z "$custom_image" ]]; then
      echo "No image entered, using default."
      CONTAINER_IMAGE="$default_image"
    else
      CONTAINER_IMAGE="$custom_image"
    fi
  else
    echo "Invalid choice, using default."
    CONTAINER_IMAGE="$default_image"
  fi

  echo "Using image: $CONTAINER_IMAGE"
}

# --- Main logic ---
echo "=== VSCode Installation ==="

case "$OS_TYPE" in
  atomic)
    install_distrobox
    if [[ "$IMAGE_PRESET" == false ]]; then
      pick_image
    fi
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
