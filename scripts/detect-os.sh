#!/bin/bash
# detect-os.sh – Detects OS type and sets variables for other scripts
# Sourced by other scripts, not executed directly.

set -euo pipefail

detect_os() {
  OS_TYPE="unknown"
  PKG_MANAGER="unknown"
  HAS_DISTROBOX=false
  HAS_FLATPAK=false
  OS_NAME="unknown"

  # Detect Atomic systems (rpm-ostree based)
  if command -v rpm-ostree &>/dev/null; then
    OS_TYPE="atomic"
    PKG_MANAGER="rpm-ostree"

    # Identify specific system
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case "$ID" in
        bazzite) OS_NAME="bazzite" ;;
        fedora)  OS_NAME="silverblue" ;;
        *)       OS_NAME="$ID" ;;
      esac
    fi

  # Detect Arch-based systems (CachyOS, EndeavourOS, etc.)
  elif command -v pacman &>/dev/null; then
    OS_TYPE="arch"
    PKG_MANAGER="pacman"

    if [ -f /etc/os-release ]; then
      . /etc/os-release
      OS_NAME="${ID:-arch}"
    fi

  # Detect Debian/Ubuntu-based systems
  elif command -v apt &>/dev/null; then
    OS_TYPE="traditional"
    PKG_MANAGER="apt"

    if [ -f /etc/os-release ]; then
      . /etc/os-release
      OS_NAME="${ID:-debian}"
    fi

  # Detect traditional Fedora (Workstation)
  elif command -v dnf &>/dev/null; then
    OS_TYPE="traditional"
    PKG_MANAGER="dnf"

    if [ -f /etc/os-release ]; then
      . /etc/os-release
      OS_NAME="${ID:-fedora}"
    fi
  fi

  # Check Distrobox and Flatpak availability
  command -v distrobox &>/dev/null && HAS_DISTROBOX=true
  command -v flatpak &>/dev/null && HAS_FLATPAK=true

  export OS_TYPE OS_NAME PKG_MANAGER HAS_DISTROBOX HAS_FLATPAK
}

print_os_info() {
  echo "=== OS Detection ==="
  echo "  OS_TYPE:        $OS_TYPE"
  echo "  OS_NAME:        $OS_NAME"
  echo "  PKG_MANAGER:    $PKG_MANAGER"
  echo "  HAS_DISTROBOX:  $HAS_DISTROBOX"
  echo "  HAS_FLATPAK:    $HAS_FLATPAK"
  echo ""
}

# Auto-execute when sourced
detect_os
