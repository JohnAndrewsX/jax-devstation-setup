#!/bin/bash
# setup.sh – Entry point for JAX DevStation Setup
# Auto-detects the OS and runs all modules in sequence.
#
# Usage:
#   bash setup.sh              # Install everything
#   bash setup.sh --dry-run    # OS detection only, no changes
#   bash setup.sh --skip-vscode  # Skip VSCode installation
#   bash setup.sh --terminal-extras  # Also install Ghostty + Zellij

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/scripts" && pwd)"

# Flags
DRY_RUN=false
SKIP_VSCODE=false
TERMINAL_EXTRAS=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)          DRY_RUN=true ;;
    --skip-vscode)      SKIP_VSCODE=true ;;
    --terminal-extras)  TERMINAL_EXTRAS=true ;;
    -h|--help)
      echo "Usage: bash setup.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run           OS detection only, no changes"
      echo "  --skip-vscode       Skip VSCode installation"
      echo "  --terminal-extras   Also install Ghostty + Zellij"
      echo "  -h, --help          Show this help"
      exit 0
      ;;
    *)
      echo "Unknown option: $1 (use --help for usage)"
      exit 1
      ;;
  esac
  shift
done

VERSION="0.0.5"

cat << EOF

███████████████████████████████████████████████████████████████████
█▌                                                               ▐█
█▌      ▐▄▄▄ ▄▄▄· ▐▄• ▄                                          ▐█
█▌       ·██▐█ ▀█  █▌█▌▪                                         ▐█
█▌     ▪▄ ██▄█▀▀█  ·██·                                          ▐█
█▌     ▐▌▐█▌▐█ ▪▐▌▪▐█·█▌                                         ▐█
█▌      ▀▀▀• ▀  ▀ •▀▀ ▀▀                                         ▐█
█▌     ·▄▄▄▄  ▄▄▄ . ▌ ▐·.▄▄ · ▄▄▄▄▄ ▄▄▄· ▄▄▄▄▄▪         ▐ ▄      ▐█
█▌     ██▪ ██ ▀▄.▀·▪█·█▌▐█ ▀. •██  ▐█ ▀█ •██  ██ ▪     •█▌▐█     ▐█
█▌     ▐█· ▐█▌▐▀▀▪▄▐█▐█•▄▀▀▀█▄ ▐█.▪▄█▀▀█  ▐█.▪▐█· ▄█▀▄ ▐█▐▐▌     ▐█
█▌     ██. ██ ▐█▄▄▌ ███ ▐█▄▪▐█ ▐█▌·▐█ ▪▐▌ ▐█▌·▐█▌▐█▌.▐▌██▐█▌     ▐█
█▌     ▀▀▀▀▀•  ▀▀▀ . ▀   ▀▀▀▀  ▀▀▀  ▀  ▀  ▀▀▀ ▀▀▀ ▀█▄▀▪▀▀ █▪     ▐█
█▌                                                               ▐█
███████████████████████████████████████████████████████████████████

  JAX DevStation Setup v${VERSION}
  Made by github.com/JohnAndrewsX

EOF

# Step 1: Detect OS
source "$SCRIPT_DIR/detect-os.sh"
print_os_info

if [ "$DRY_RUN" = true ]; then
  echo "Dry run complete. No changes made."
  exit 0
fi

# Step 2: VSCode (via Distrobox on Atomic, native otherwise)
if [ "$SKIP_VSCODE" = false ]; then
  bash "$SCRIPT_DIR/distrobox.sh"
else
  echo "=== VSCode installation skipped (--skip-vscode) ==="
  echo ""
fi

# Step 3: Node.js toolchain (fnm + Node + pnpm)
bash "$SCRIPT_DIR/node.sh"

# Step 4: Claude Code CLI
bash "$SCRIPT_DIR/claude-code.sh"

# Step 5: Terminal tools
if [ "$TERMINAL_EXTRAS" = true ]; then
  bash "$SCRIPT_DIR/terminal.sh" --all
else
  bash "$SCRIPT_DIR/terminal.sh"
fi

# Step 6: Shell configuration
bash "$SCRIPT_DIR/shell.sh"

# Step 7: VSCode extensions
if [ "$SKIP_VSCODE" = false ]; then
  bash "$SCRIPT_DIR/vscode-ext.sh"
fi

echo ""
echo "========================================"
echo "  Setup complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Start a new shell: source ~/.bashrc"
echo "  2. Authenticate Claude Code: claude"
echo "  3. Launch VSCode and verify"
echo ""
echo "Versions:"
command -v node  &>/dev/null && echo "  node:   $(node -v)"  || echo "  node:   not found"
command -v pnpm  &>/dev/null && echo "  pnpm:   $(pnpm -v)"  || echo "  pnpm:   not found"
command -v claude &>/dev/null && echo "  claude: installed"   || echo "  claude: not found"
command -v tmux  &>/dev/null && echo "  tmux:   $(tmux -V)"  || echo "  tmux:   not found"
command -v code  &>/dev/null && echo "  code:   $(code --version 2>/dev/null | head -1)" || echo "  code:   not found"
echo ""
