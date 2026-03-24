```text
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
```

# JAX DevStation Setup

**Version:** 0.0.5 | [GitHub](https://github.com/JohnAndrewsX/jax-devstation-setup)

Reproducible development environment for vibecoding with Claude Code across heterogeneous Linux systems.

## Quick Start

```bash
git clone https://github.com/JohnAndrewsX/jax-devstation-setup.git
cd jax-devstation-setup
bash setup.sh
```

The script auto-detects the running OS and selects the correct installation path.

## Target Systems

| System | Type | VSCode Installation |
| ------ | ---- | ------------------- |
| Fedora Silverblue | Atomic | Distrobox + Export |
| Bazzite | Atomic | Distrobox + Export |
| CachyOS | Arch-based | pacman (native) |
| Ubuntu | Traditional | apt (native) |

## What Gets Installed

| Component | Tool | Details |
| --------- | ---- | ------- |
| Editor | VSCode | + Extensions (Claude Code, Astro, Svelte, Tailwind, Prettier, ESLint) |
| AI CLI | Claude Code | Native Installer, auto-updates, MCP configuration |
| Runtime | Node.js LTS | via fnm (Fast Node Manager), auto-switch per `.node-version` |
| Packages | pnpm | via Corepack |
| Multiplexer | tmux | Base for Claude Code Agent Teams |
| Shell | bash | fnm hook, PATH configuration via `~/.bashrc.d/` |

## Project Structure

```text
jax-devstation-setup/
├── setup.sh                  # Entry point
├── scripts/
│   ├── detect-os.sh          # OS detection
│   ├── distrobox.sh          # Container + VSCode (Atomic OS)
│   ├── node.sh               # fnm + Node.js + pnpm
│   ├── claude-code.sh        # Claude Code CLI + MCP
│   ├── terminal.sh           # tmux (+ optional tools)
│   ├── shell.sh              # Shell configuration
│   └── vscode-ext.sh         # Extensions + Settings
├── config/
│   ├── vscode-extensions.txt # Extension list
│   ├── vscode-settings.json  # Recommended settings
│   ├── bashrc.d/fnm.sh       # fnm shell hook
│   └── mcp/mcp-servers.json  # MCP server config
└── docs/
    ├── architecture.md       # Architecture decisions
    ├── os-compatibility.md   # OS matrix
    ├── terminal-tools.md     # Terminal tool research
    └── troubleshooting.md    # Known issues
```

## Architecture Decisions

| Decision | Why |
| -------- | --- |
| Distrobox over rpm-ostree layering | No reboot, clean atomic updates, identical across systems |
| Distrobox over Flatpak for VSCode | Flatpak sandboxes away host toolchains (Node.js, pnpm, Git hooks) |
| fnm over nvm | Faster (Rust), `.node-version` auto-switch, simpler shell integration |
| Claude Code Native Installer | No npm required, auto-updates, officially recommended |
| tmux as multiplexer base | Claude Code Agent Teams use tmux natively |
| Idempotent scripts | Safe to re-run without side effects |

## Documentation

- [Architecture Decisions](docs/architecture.md)
- [OS Compatibility](docs/os-compatibility.md)
- [Terminal Tools Research](docs/terminal-tools.md)
- [Troubleshooting](docs/troubleshooting.md)
