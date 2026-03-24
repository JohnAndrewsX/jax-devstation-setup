#!/bin/bash
# node.sh – Installs fnm + Node.js LTS + pnpm
# Runs on the host (home directory), no container needed.

set -euo pipefail

install_fnm() {
  if command -v fnm &>/dev/null; then
    echo "fnm already installed: $(fnm --version)"
    return
  fi

  echo "Installing fnm..."
  curl -fsSL https://fnm.vercel.app/install | bash

  # Make fnm available immediately
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "$(fnm env)"
}

install_node() {
  # Load fnm env if not yet active
  if ! command -v fnm &>/dev/null; then
    export PATH="$HOME/.local/share/fnm:$PATH"
    eval "$(fnm env)"
  fi

  echo "Installing Node.js LTS..."
  fnm install --lts
  fnm default lts-latest

  echo "Node.js installed: $(node -v)"
}

install_pnpm() {
  echo "Activating pnpm via Corepack..."
  corepack enable
  corepack prepare pnpm@latest --activate

  echo "pnpm installed: $(pnpm -v)"
}

# --- Main logic ---
echo "=== Node.js Toolchain ==="

install_fnm
install_node
install_pnpm

echo ""
echo "Summary:"
echo "  fnm:  $(fnm --version)"
echo "  node: $(node -v)"
echo "  pnpm: $(pnpm -v)"
echo ""
