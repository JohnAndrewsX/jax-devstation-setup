#!/bin/bash
# claude-code.sh – Installs Claude Code CLI (Native Installer) + MCP config

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

install_claude_code() {
  if command -v claude &>/dev/null; then
    echo "Claude Code already installed: $(claude --version 2>/dev/null || echo 'installed')"
    return
  fi

  echo "Installing Claude Code CLI (Native Installer)..."
  curl -fsSL https://claude.ai/install.sh | bash

  # Update PATH
  export PATH="$HOME/.local/bin:$PATH"
}

setup_mcp() {
  local mcp_source="$PROJECT_DIR/config/mcp/mcp-servers.json"
  local claude_dir="$HOME/.claude"

  if [ ! -f "$mcp_source" ]; then
    echo "No MCP configuration found, skipping."
    return
  fi

  mkdir -p "$claude_dir"

  if [ -f "$claude_dir/mcp-servers.json" ]; then
    echo "MCP configuration already exists at $claude_dir/"
    echo "  Source:  $mcp_source"
    echo "  Target:  $claude_dir/mcp-servers.json"
    echo "  Skipping (update manually if needed)."
    return
  fi

  echo "Copying MCP configuration..."
  cp "$mcp_source" "$claude_dir/mcp-servers.json"
  echo "MCP configuration installed: $claude_dir/mcp-servers.json"
}

# --- Main logic ---
echo "=== Claude Code CLI ==="

install_claude_code
setup_mcp

echo "Claude Code installation complete."
echo "  Run 'claude' and follow the browser prompts to authenticate."
echo ""
