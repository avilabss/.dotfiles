# .dotfiles

Personal dotfiles for macOS, Debian/Ubuntu, and Fedora, managed with Ansible and GNU Stow.

## Quick Install

```bash
git clone https://github.com/avilabss/.dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

## Usage

```bash
./bootstrap.sh                            # Core setup
./bootstrap.sh --all                      # Everything (core + optional)
./bootstrap.sh --tags docker,ssh          # Specific optional roles
./bootstrap.sh --tags ghostty,google-chrome,flameshot,openwhispr,waydroid  # Desktop apps only
./bootstrap.sh --tags zsh                 # Re-run a single role
./bootstrap.sh --check                    # Dry run
```

## What Gets Installed

### Core

| Tool | Description |
|------|-------------|
| Neovim | Editor with LSP, completion, debugging, Telescope |
| Zsh | Shell with Oh My Zsh framework |
| Tmux | Terminal multiplexer with vim navigation |
| Starship | Cross-shell prompt |
| JetBrainsMono Nerd Font | Terminal font |
| btop | Resource monitor |
| ripgrep | Fast search |
| fastfetch | System info summary; kept as core even where a distro package is unavailable |
| go, rust, node, python | Language runtimes |
| pipx, uv, poetry | Package managers |
| git, git-lfs | Version control |

### Optional (via tags)

| Tag | Description | Platforms |
|-----|-------------|-----------|
| `opencode` | AI coding agent (config + agents) | All |
| `openchamber` | Web/PWA workspace for OpenCode | All |
| `ghostty` | Ghostty terminal emulator + stowed config | All |
| `google-chrome` / `chrome` | Google Chrome browser | All |
| `flameshot` | Screenshot tool | All |
| `openwhispr` | Local/cloud voice dictation with system-wide text insertion | Linux x86_64 |
| `docker` | Docker / OrbStack | All |
| `ssh` | OpenSSH server + firewall | Linux |
| `xrdp` | Remote desktop (RDP) | Linux |
| `sunshine` | Remote desktop (Moonlight/Sunshine) | All |
| `qemu` | QEMU guest agent (Proxmox/KVM) | Linux |
| `waydroid` | GAPPS Waydroid, networking, game-compatible single-surface mode, and KDE session launcher | Fedora |

## Package Failures on Unsupported Hosts

Packages stay declared in dotfiles even when a host cannot install one of them. For example, `fastfetch` is part of the core package set, but some Raspberry Pi OS / Debian releases may not provide a package for it. Optional packages can hit the same case when an upstream repository does not publish a build for a specific release or architecture, such as Ghostty's COPR or Sunshine's release assets. In that case the bootstrap warns, skips that package on that host, and prints a failed-package summary at the end instead of removing it from the repo.

## Install Sources

- **Docker on Debian/Ubuntu:** Official Docker apt repository and signed packages; unsupported Debian-family derivatives skip with a warning.
- **Ghostty on Fedora:** `scottames/ghostty` COPR.
- **Ghostty on Ubuntu:** Community Ubuntu installer script; skipped with a warning on unsupported Debian-family distributions.
- **Sunshine on Ubuntu:** GitHub release `.deb` assets for configured Ubuntu releases and architectures; skipped with a warning otherwise.
- **Sunshine on Fedora:** LizardByte COPR with graceful skip behavior if the COPR is unavailable for the host.
- **Google Chrome on Fedora:** Google RPM with the Google Linux signing key imported; GPG checks remain enabled.
- **OpenWhispr on Linux:** Latest official GitHub release RPM/DEB for x86_64, plus `wl-clipboard` for Wayland text insertion. Unsupported architectures or unavailable releases are skipped with a warning.
- **OpenChamber:** Official `@openchamber/web` npm package installed under the user-local `~/.local` prefix. The shell also exports `NPM_CONFIG_PREFIX=~/.local`, so OpenChamber's built-in updater does not write to a sudo-owned global npm directory.
- **Waydroid on Fedora:** Fedora's package, initialized with GAPPS. The role enables the container, configures firewalld forwarding/NAT, applies Docker forwarding rules only while the `waydroid0` interface exists, and stows a KDE launcher for background session start/stop and individual apps.

## Adding Packages

Edit the `group_vars` file for your platform:

- **macOS:** `ansible/group_vars/macos.yml`
- **Debian/Ubuntu:** `ansible/group_vars/debian.yml`
- **Fedora:** `ansible/group_vars/fedora.yml`

## OpenCode

Install OpenCode and its stowed configuration with
`./bootstrap.sh --tags opencode`. The optional role stows this package
separately from the common role and reports existing-file conflicts rather than
adopting them.

Run `opencode`, then `/connect`, select **OpenAI (ChatGPT Plus/Pro)**, and
complete browser OAuth. Credentials are stored outside this repository at
`~/.local/share/opencode/auth.json`.

`@architect` is the default entry point. The workflow has two explicit user
approval gates: agreement on requirements, then approval of the task plan.
Architect may invoke repo-scouter only when existing repository guidance is
materially insufficient, then creates a local Task Brief and delegates to
`@developer`. Developer implements and requests both code reviews in parallel;
reviewers return results to developer, who iterates until both approve and
reports the consolidated outcome to architect.

Inside OpenCode, use `/harvest [scope]` for read-only knowledge harvesting and
`/wb-start <ticket-link> <branch-name> [context]` for Whitebox development.

See the [internal OpenCode guide](opencode/.config/opencode/README.md) for model
and runtime behavior, role permissions, the complete workflow, commands,
skills, and server operation. Restart OpenCode and OpenChamber after applying
stowed config-time changes.

### Server helpers

```bash
opencode-serve-start
opencode-serve-stop
opencode-db-vacuum
openchamber-serve-start
openchamber-serve-stop
```

These manually run the standalone OpenCode server, database maintenance, or the
optional OpenChamber web interface. Detailed defaults and environment overrides
are in the internal guide.

## Post-Install

1. Restart your terminal (or `source ~/.zshrc`)
2. Open neovim — Lazy will auto-install plugins
3. Run `opencode`, then `/connect` to authenticate OpenAI (ChatGPT Plus/Pro)

Tmux plugins, including the Catppuccin theme, are installed automatically by
the bootstrap. Terminal setup runs before development tools and Neovim so an
unrelated later failure does not leave the shell prompt or tmux theme missing.

## Theme

All tools use **Catppuccin Mocha**.
