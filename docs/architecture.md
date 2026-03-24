# Architecture Decisions

## Distrobox Over rpm-ostree Layering

**Problem:** Atomic systems (Silverblue, Bazzite) have a read-only root filesystem. Software can be layered via `rpm-ostree install`, but this requires a reboot and slows down updates.

**Decision:** VSCode and build tools run in a Distrobox container (Fedora image, version configured in `distrobox.sh`). `distrobox-export --app code` makes VSCode available in the host application menu.

**Advantages:**

- No reboot after installation
- Atomic updates remain clean (no layer conflicts)
- Identical installation path across all Atomic systems
- Container can be recreated at any time

**Disadvantages:**

- Initial setup takes longer (container image download)
- VSCode technically runs inside a container (transparent to the user)

## Distrobox Over Flatpak for VSCode

**Problem:** VSCode as a Flatpak cannot access host toolchains (Node.js, pnpm, Git hooks). Flatpak sandboxes everything.

**Decision:** Install VSCode in a Distrobox container or natively. No Flatpak.

## fnm Over nvm

**Problem:** nvm is slow (shell startup +200-500ms), purely Bash-based, and has no native `.node-version` auto-switch.

**Decision:** fnm (Fast Node Manager) – written in Rust, ~40x faster than nvm, supports `.node-version` auto-switch via `--use-on-cd`.

**Installation:** Fully contained in `~/.local/share/fnm/` – no root access needed, works on any system.

## Claude Code Native Installer Over npm

**Problem:** The npm installation requires Node.js as a prerequisite and is marked as deprecated by Anthropic.

**Decision:** Native Installer (`curl -fsSL https://claude.ai/install.sh | bash`). Installs to `~/.local/bin/claude`, auto-updates in the background.

**Advantage:** Can be installed before Node.js is set up. No npm dependency.

## tmux as Base Multiplexer

**Problem:** Multiple terminal tools exist (seemux, Zellij, Ghostty). Which one as default?

**Decision:** tmux as the base, because Claude Code Agent Teams use tmux natively. Zellij and Ghostty are available as optional extras.

**Other options (evaluated, not default):**

- **seemux:** Strongest Claude integration, but young project (small community, needs Rust toolchain to build)
- **Zellij:** Modern tmux replacement, better UX, but no official Claude support yet
- **Ghostty:** GPU-accelerated terminal emulator (not a multiplexer), combinable with tmux/Zellij

## Idempotent Scripts

Every script checks whether a tool is already installed before taking action. `bash setup.sh` can be run any number of times without side effects or errors.
