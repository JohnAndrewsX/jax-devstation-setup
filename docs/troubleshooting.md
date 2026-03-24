# Troubleshooting

## VSCode Flatpak Cannot Access Node.js/pnpm

**Problem:** VSCode as a Flatpak sandboxes all host toolchains. Node.js, pnpm, Git hooks, etc. are unreachable.

**Solution:** Uninstall VSCode Flatpak and install natively or via Distrobox:

```bash
flatpak uninstall com.visualstudio.code
bash scripts/distrobox.sh  # or install directly
```

## fnm/node/pnpm Not Found After Installation

**Problem:** After running `bash scripts/node.sh`, the tools are not in PATH.

**Solution:** Run the shell configuration script and start a new shell:

```bash
bash scripts/shell.sh
source ~/.bashrc
```

Or verify that `~/.bashrc.d/fnm.sh` exists and is correct.

## Corepack: Permission Denied

**Problem:** `corepack enable` fails with a permission error.

**Cause:** Corepack tries to write to a system directory.

**Solution:** Ensure Node.js is installed via fnm (home directory). Then corepack needs no sudo:

```bash
which node  # Should show ~/.local/share/fnm/...
corepack enable  # Without sudo
```

## VSCode Does Not Appear in App Menu After Distrobox Export

**Problem:** `distrobox-export --app code` was run, but VSCode does not appear in the GNOME menu.

**Solution:**

1. Restart the shell
2. If that doesn't help: log out and log back in
3. Check if the .desktop file exists: `ls ~/.local/share/applications/ | grep code`

## Claude Code: Authentication Fails

**Problem:** `claude` starts, but browser redirect does not work.

**Solution:**

1. Check if a browser is available
2. If in an SSH session: `claude --no-browser` and copy the URL manually
3. Check account type: the free plan does not include Claude Code access (Pro, Max, Teams, or Enterprise required)

## Distrobox: Container Creation Fails

**Problem:** `distrobox create` fails.

**Possible causes:**

- Podman not installed: check with `command -v podman`
- No internet connection (container image cannot be pulled)
- SELinux blocking: check with `sudo ausearch -m avc -ts recent`

**Solution on Bazzite/Silverblue:** Podman is pre-installed. If not: `rpm-ostree install podman` + reboot.

## tmux in Distrobox Container Not Available on Host

**Problem:** tmux was installed in the container but is not callable from the host.

**Solution:** Export tmux from the container:

```bash
distrobox enter dev -- distrobox-export --bin /usr/bin/tmux --export-path ~/.local/bin
```

Or work directly inside the container: `distrobox enter dev`
