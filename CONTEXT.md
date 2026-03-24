# JAX DevStation Setup

> Reproducible development environment for vibecoding with Claude Code across heterogeneous Linux systems.

**GitHub:** https://github.com/JohnAndrewsX/jax-devstation-setup

## Goal

A single `bash setup.sh` provisions a complete dev environment on any of the 4 target systems:
VSCode + Claude Code CLI + Node.js/pnpm + terminal multiplexer + MCP servers.

## Target Systems

| System | Type | Package Manager |
| ------ | ---- | --------------- |
| Fedora Silverblue | Atomic (rpm-ostree) | rpm-ostree + Distrobox |
| Bazzite | Atomic (rpm-ostree) | rpm-ostree + Distrobox |
| CachyOS | Arch-based | pacman |
| Ubuntu | Traditional (deb) | apt |

## Key Decisions

- **VSCode via Distrobox** on Atomic systems (no rpm-ostree layering, no Flatpak sandbox issues)
- **fnm** over nvm (faster, Rust-based, `.node-version` auto-switch)
- **Claude Code Native Installer** (no npm required, auto-updates)
- **tmux** as base multiplexer (Claude Code Agent Teams use tmux natively)
- **Idempotent scripts** (every step checks before acting)

## Stack

| Component | Tool | Install Location |
| --------- | ---- | ---------------- |
| Editor | VSCode | Distrobox (Atomic) / native (Arch/Deb) |
| AI CLI | Claude Code | ~/.local/bin/ (Native Installer) |
| Node.js | fnm + Node LTS | ~/.local/share/fnm/ |
| Packages | pnpm (Corepack) | Home directory |
| Multiplexer | tmux | Distrobox / native |
| MCP | Configurable | ~/.claude/ |
