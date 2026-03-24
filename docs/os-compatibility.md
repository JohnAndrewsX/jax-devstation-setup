# OS Compatibility

## Matrix

| Component | Silverblue | Bazzite | CachyOS | Ubuntu |
| --------- | ---------- | ------- | ------- | ------ |
| VSCode | Distrobox | Distrobox | pacman/AUR | apt |
| fnm | curl (Home) | curl (Home) | curl (Home) | curl (Home) |
| Node.js | fnm | fnm | fnm | fnm |
| pnpm | Corepack | Corepack | Corepack | Corepack |
| Claude Code | Native Installer | Native Installer | Native Installer | Native Installer |
| tmux | Distrobox | Distrobox | pacman | apt |
| Ghostty | AppImage/Distrobox | AppImage/Distrobox | pacman/AUR | Snap/Source |
| Zellij | Binary (~/.local/bin) | Binary (~/.local/bin) | Binary (~/.local/bin) | Binary (~/.local/bin) |
| .bashrc.d/ | Present (default) | Present (default) | Manual setup | Manual setup |
| Distrobox | Pre-installed | Pre-installed | Manual install | Manual install |

## OS Detection

The script `scripts/detect-os.sh` detects the OS type based on available commands:

1. `rpm-ostree` present → `atomic` (Silverblue/Bazzite)
2. `pacman` present → `arch` (CachyOS)
3. `apt` present → `traditional` (Ubuntu)
4. `dnf` present → `traditional` (Fedora Workstation)

## Atomic OS Specifics

- **No `sudo dnf install`** – the root filesystem is read-only
- **`rpm-ostree install`** works but requires a reboot – we avoid this
- **Distrobox** is the recommended solution for development tools
- **`~/.bashrc.d/`** is sourced by default on Silverblue/Bazzite
- **Flatpak** is available but unsuitable for dev tools (sandbox)

## CachyOS Specifics

- Arch-based, uses `pacman` + AUR
- Distrobox not pre-installed (installed on demand)
- VSCode via AUR: `yay -S visual-studio-code-bin`

## Ubuntu Specifics

- Distrobox not pre-installed
- VSCode via Microsoft APT repo
- `~/.bashrc.d/` must be manually added to `~/.bashrc`
