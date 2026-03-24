#!/bin/bash
# shell.sh – Installs shell configuration (fnm hook, PATH)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

BASHRC_D="$HOME/.bashrc.d"

setup_bashrc_d() {
  mkdir -p "$BASHRC_D"

  # On Fedora Silverblue/Bazzite, ~/.bashrc.d/ is sourced by default.
  # On other systems, we need to ensure it.
  if ! grep -q 'bashrc.d' "$HOME/.bashrc" 2>/dev/null; then
    echo "Adding .bashrc.d/ sourcing to ~/.bashrc..."
    cat >> "$HOME/.bashrc" << 'EOF'

# Source all files in ~/.bashrc.d/
if [ -d ~/.bashrc.d ]; then
  for f in ~/.bashrc.d/*.sh; do
    [ -r "$f" ] && source "$f"
  done
fi
EOF
  else
    echo "~/.bashrc already sources .bashrc.d/"
  fi
}

install_fnm_hook() {
  local source_file="$PROJECT_DIR/config/bashrc.d/fnm.sh"
  local target_file="$BASHRC_D/fnm.sh"

  if [ ! -f "$source_file" ]; then
    echo "WARNING: $source_file not found." >&2
    return 1
  fi

  if [ -f "$target_file" ] && diff -q "$source_file" "$target_file" &>/dev/null; then
    echo "fnm shell hook already up to date."
    return
  fi

  echo "Installing fnm shell hook..."
  cp "$source_file" "$target_file"
  echo "  -> $target_file"
}

# --- Main logic ---
echo "=== Shell Configuration ==="

setup_bashrc_d
install_fnm_hook

echo "Shell configuration complete."
echo "  Start a new shell or run 'source ~/.bashrc'."
echo ""
