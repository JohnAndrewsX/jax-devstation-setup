# Terminal Tools Research

## Context

Working with Claude Code in the terminal requires a multiplexer that can manage multiple sessions in parallel. On macOS there's cmux (Swift/AppKit, Ghostty-based) – on Linux there are several alternatives.

## Candidates

### tmux (Default)

- **What:** Terminal multiplexer, the classic
- **Platform:** Everywhere (pre-installed on many systems)
- **Claude integration:** Claude Code Agent Teams use tmux natively
- **Maturity:** Battle-tested, extremely stable
- **Pros:** Just works, available everywhere, Agent Teams compatible
- **Cons:** Steep learning curve, prefix keys, dated UX
- **Verdict:** Base tool, always install

### seemux

- **What:** GTK4 terminal multiplexer for Linux, inspired by cmux
- **Platform:** Linux only (GTK4 4.12+ / VTE4 0.76+)
- **Repo:** https://github.com/asermax/seemux
- **Claude integration:** Native – Unix socket communication, real-time status (Running, Needs Input, Completed, Error), desktop notifications, Agent Teams support
- **Maturity:** Early-stage project, small community
- **Installation:** `cargo build --release` (requires Rust toolchain)
- **Pros:** Strongest Claude integration of all Linux tools, session persistence, tab groups, system tray
- **Cons:** Very young project, small community, Rust + GTK4 build dependencies, harder on Atomic OS
- **Verdict:** Promising but too early for production use as default

### CodeMux

- **What:** Specialized terminal multiplexer for AI coding CLIs
- **Platform:** Linux, macOS, WSL
- **Repo:** https://github.com/codemuxlab/codemux-cli
- **Claude integration:** Claude-optimized, web UI for prompt interception, session management
- **Maturity:** Early-stage, server-client architecture (React Native)
- **Installation:** `npm install -g codemux`
- **Pros:** Easy installation, cross-platform, web UI
- **Cons:** Early-stage, only Claude fully supported, other agents "Coming Soon"
- **Verdict:** Interesting but not mature enough

### Coder Mux

- **What:** Desktop & browser app for parallel AI agent development
- **Platform:** Linux, macOS
- **Repo:** https://github.com/coder/mux
- **Claude integration:** Multi-LLM (Sonnet, GPT-5, Opus), Plan/Exec mode, own LLM client
- **Maturity:** Active project, large community, AGPL-3.0
- **Installation:** Binary from releases
- **Pros:** Most mature, active community, multi-LLM, VSCode extension
- **Cons:** Own app with own LLM client (not just a multiplexer), AGPL license
- **Verdict:** Good tool but different scope than a terminal multiplexer

### Ghostty

- **What:** GPU-accelerated terminal emulator (not a multiplexer!)
- **Platform:** Linux (GTK), macOS
- **Website:** https://ghostty.org/
- **Maturity:** By Mitchell Hashimoto (HashiCorp), actively maintained
- **Installation:** COPR (Fedora), pacman/AUR (Arch), Snap (Ubuntu), AppImage
- **Pros:** Extremely fast (GPU-accelerated), platform-native, good defaults
- **Cons:** Not a multiplexer (needs tmux/Zellij), non-trivial on Atomic OS
- **Verdict:** Excellent terminal emulator, combinable with tmux/Zellij

### Zellij

- **What:** Modern terminal multiplexer (tmux alternative)
- **Platform:** Linux, macOS
- **Repo:** https://github.com/zellij-org/zellij
- **Maturity:** Stable, large community, Rust-based
- **Installation:** Binary, Cargo, COPR (Fedora), Snap
- **Pros:** Better UX than tmux, no prefix keys, plugin system, floating panes
- **Cons:** No official Claude Code Agent Teams support yet (feature request open)
- **Verdict:** Best tmux alternative, once Agent Teams support lands

## Recommendation

1. **tmux** – always install (Agent Teams compatibility)
2. **Ghostty + Zellij** – evaluate as comfort upgrade
3. **seemux** – watch for maturity; best option for Claude workflow if it grows
4. **CodeMux / Coder Mux** – niche, test on demand

## Sources

- https://cmux.com/ (cmux – macOS only)
- https://github.com/asermax/seemux
- https://www.codemux.dev/
- https://github.com/coder/mux
- https://ghostty.org/
- https://zellij.dev/
- https://github.com/anthropics/claude-code/issues/24122 (Zellij support request)
