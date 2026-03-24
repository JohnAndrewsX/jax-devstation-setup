#!/bin/bash
# terminal.sh – Installs terminal multiplexer(s)
# tmux is the base (Claude Code Agent Teams use tmux natively).
# Optional tools: ghostty, zellij (via flags).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/detect-os.sh"

CONTAINER_NAME="devstation"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --container-name) CONTAINER_NAME="$2"; shift ;;
    --zellij|--ghostty|--all) break ;;  # Rest wird unten geparst
    *) break ;;
  esac
  shift
done

install_tmux() {
  if command -v tmux &>/dev/null; then
    echo "tmux already installed: $(tmux -V)"
    return
  fi

  echo "Installing tmux..."
  case "$OS_TYPE" in
    atomic)
      # Install in Distrobox container and export to host
      if distrobox list 2>/dev/null | grep -q "$CONTAINER_NAME"; then
        distrobox enter "$CONTAINER_NAME" -- sudo dnf install -y tmux
        mkdir -p "$HOME/.local/bin"
        distrobox enter "$CONTAINER_NAME" -- distrobox-export --bin /usr/bin/tmux --export-path ~/.local/bin
      else
        echo "WARNING: Distrobox container '$CONTAINER_NAME' not found. Run distrobox.sh first." >&2
        return 1
      fi
      ;;
    arch)
      sudo pacman -S --noconfirm tmux
      ;;
    traditional)
      case "$PKG_MANAGER" in
        apt) sudo apt install -y tmux ;;
        dnf) sudo dnf install -y tmux ;;
      esac
      ;;
  esac
}

install_zellij() {
  if command -v zellij &>/dev/null; then
    echo "zellij already installed: $(zellij --version)"
    return
  fi

  echo "Installing zellij..."
  mkdir -p "$HOME/.local/bin"

  # Prefer pre-built binary (works everywhere)
  local version
  version=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name"' | sed 's/.*"v\(.*\)".*/\1/')

  if [ -n "$version" ]; then
    local url="https://github.com/zellij-org/zellij/releases/download/v${version}/zellij-x86_64-unknown-linux-musl.tar.gz"
    echo "  Downloading zellij v${version}..."
    curl -fsSL "$url" | tar -xz -C /tmp
    install -m 755 /tmp/zellij "$HOME/.local/bin/zellij"
    rm -f /tmp/zellij
    echo "  Installed: $HOME/.local/bin/zellij"
  else
    echo "WARNING: Could not determine zellij version. Install manually." >&2
    return 1
  fi
}

install_ghostty() {
  if command -v ghostty &>/dev/null; then
    echo "ghostty already installed."
    return
  fi

  echo "Installing Ghostty..."
  case "$OS_TYPE" in
    atomic)
      echo "  Ghostty on Atomic OS: recommend AppImage or Distrobox."
      echo "  See: https://ghostty.org/docs/install/binary"
      echo "  Skipping automatic installation."
      ;;
    arch)
      sudo pacman -S --noconfirm ghostty 2>/dev/null || {
        echo "  Ghostty not in pacman repos. Trying AUR..."
        if command -v yay &>/dev/null; then
          yay -S --noconfirm ghostty
        else
          echo "  WARNING: No AUR helper found. Install manually." >&2
        fi
      }
      ;;
    traditional)
      case "$PKG_MANAGER" in
        dnf)
          sudo dnf copr enable -y scottames/ghostty 2>/dev/null || true
          sudo dnf install -y ghostty
          ;;
        apt)
          echo "  Ghostty on Ubuntu: use Snap or build from source."
          echo "  See: https://ghostty.org/docs/install/binary"
          echo "  Skipping automatic installation."
          ;;
      esac
      ;;
  esac
}

# --- Main logic ---
echo "=== Terminal Tools ==="

# Always install tmux (base for Agent Teams)
install_tmux

# Optional tools via flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --zellij)  install_zellij  ;;
    --ghostty) install_ghostty ;;
    --all)
      install_zellij
      install_ghostty
      ;;
    *)
      echo "Unknown option: $1"
      echo "Usage: terminal.sh [--zellij] [--ghostty] [--all]"
      ;;
  esac
  shift
done

echo "Terminal tools installation complete."
echo ""
