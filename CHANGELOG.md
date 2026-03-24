# Changelog

All notable changes to JAX DevStation Setup will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.7] - 2026-03-24

### Fixed

- Stale container bug: `create_container()` now verifies the underlying podman/docker container exists before skipping creation
- Substring matching bug: container name check uses word-boundary match (`grep -qw`) to prevent false positives

## [0.0.6] - 2026-03-24

### Added

- Interactive container image selection for Distrobox (`pick_image()`)

## [0.0.5] - 2026-03-24

### Added

- GitHub repository URL throughout project (README, CONTEXT, setup.sh)
- Concrete `git clone` URL in Quick Start

## [0.0.4] - 2026-03-24

### Added

- ASCII art logo in `setup.sh` terminal output and `README.md`

## [0.0.3] - 2026-03-24

### Changed

- Removed volatile data from documentation (version numbers, star counts, commit counts, contributor counts)
- Replaced with qualitative descriptions (e.g. "early-stage", "active project", "large community")
- Added maintenance comment to hardcoded Fedora container image version in `distrobox.sh`

## [0.0.2] - 2026-03-24

### Changed

- Translated all files from German to English (scripts, docs, configs)
- Renamed project to "JAX DevStation Setup"
- Moved project to `global/jax-devstation-setup/`

### Fixed

- tmux on Atomic OS: now exports binary to host via `distrobox-export --bin`
- Added `mkdir -p ~/.local/bin` before tmux export on Atomic OS
- Warnings and errors now write to stderr (`>&2`)

### Added

- Shell Scripting skill for ATLAS (`user/skills/shell-scripting.md`)

## [0.0.1] - 2026-03-24

### Added

- Initial project structure with modular scripts
- OS detection (`detect-os.sh`) for Atomic, Arch, and Traditional Linux
- VSCode installation via Distrobox (Atomic) or native package manager
- Node.js toolchain: fnm + Node.js LTS + pnpm via Corepack
- Claude Code CLI via Native Installer + MCP configuration
- Shell configuration with `.bashrc.d/` pattern and fnm auto-switch hook
- VSCode extensions list and recommended settings
- Terminal tools: tmux (base) + optional Ghostty and Zellij
- Documentation: architecture decisions, OS compatibility, terminal tools research, troubleshooting
