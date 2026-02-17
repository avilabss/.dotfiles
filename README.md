# .dotfiles

Personal dotfiles for macOS, Debian/Ubuntu, and Fedora, managed with Ansible and GNU Stow.

## Quick Install

```bash
git clone https://github.com/avilabss/.dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The bootstrap script will:
1. Detect your OS (macOS / Debian / Fedora)
2. Install Ansible if not present
3. Run the Ansible playbook to set everything up

## Optional Features

Optional roles (Docker, SSH, xrdp, QEMU) are skipped by default. Opt in with `--tags`:

```bash
# Include Docker
./bootstrap.sh --tags all,docker

# Include Docker + SSH server
./bootstrap.sh --tags all,docker,ssh

# Include everything
./bootstrap.sh --tags all,docker,ssh,xrdp,qemu
```

## Selective Setup

Re-run only specific roles:

```bash
# Only re-stow configs
./bootstrap.sh --tags common

# Only re-run zsh setup
./bootstrap.sh --tags zsh

# Dry run (preview changes)
./bootstrap.sh --check
```

## What Gets Installed

### Core Tools (all platforms)

| Tool | Description |
|------|-------------|
| Neovim | Editor with LSP, completion, debugging, Telescope |
| Zsh | Shell with Oh My Zsh framework |
| Tmux | Terminal multiplexer with vim navigation |
| Starship | Cross-shell prompt |
| Ghostty | Terminal emulator |
| Google Chrome | Browser |
| JetBrainsMono Nerd Font | Terminal font |

### Additional Tools

| Tool | Description |
|------|-------------|
| fastfetch | System info |
| ripgrep | Fast search |
| git, git-lfs | Version control |
| go, node, pipx, uv | Language runtimes & package managers |
| flameshot | Screenshots |

### Optional (via tags)

| Tag | Description | Platforms |
|-----|-------------|-----------|
| `docker` | Docker / OrbStack | All |
| `ssh` | OpenSSH server + firewall | Linux |
| `xrdp` | Remote desktop (RDP) | Linux |
| `sunshine` | Remote desktop (Moonlight/Sunshine) | All |
| `qemu` | QEMU guest agent (Proxmox/KVM) | Linux |

## Directory Structure

```
~/dotfiles/
├── bootstrap.sh               # Run this to set up
├── ansible/
│   ├── site.yml               # Main playbook
│   ├── group_vars/
│   │   ├── all.yml            # Common variables
│   │   ├── macos.yml          # macOS-specific
│   │   ├── debian.yml         # Debian/Ubuntu-specific
│   │   └── fedora.yml         # Fedora-specific
│   └── roles/                 # Ansible roles
│       ├── common/            # Package install + stow
│       ├── zsh/               # Oh My Zsh + plugins
│       ├── nvim/              # Neovim
│       ├── tmux/              # TPM
│       ├── starship/          # Starship prompt
│       ├── ghostty/           # Ghostty terminal
│       ├── fonts/             # Nerd fonts
│       ├── dev_tools/         # Go, Node, Python, Chrome
│       ├── docker/            # Docker (optional)
│       ├── ssh/               # SSH server (optional)
│       ├── xrdp/              # xrdp (optional)
│       └── qemu/              # QEMU agent (optional)
├── nvim/.config/nvim/         # Neovim config (stowed)
├── zsh/
│   ├── .zshrc                 # Zsh config (stowed)
│   └── .zprofile              # Zsh profile (stowed)
├── tmux/.tmux.conf            # Tmux config (stowed)
├── starship/.config/starship.toml
└── ghostty/.config/ghostty/
```

## Adding Packages

**macOS:** Edit `ansible/group_vars/macos.yml`, add to `common_packages`, `dev_tool_packages`, or `brew_casks`

**Debian/Ubuntu:** Edit `ansible/group_vars/debian.yml`, add to `common_packages` or `dev_tool_packages`

**Fedora:** Edit `ansible/group_vars/fedora.yml`, add to `common_packages` or `dev_tool_packages`

## Post-Install

1. Restart your terminal (or `source ~/.zshrc`)
2. In tmux, press `Ctrl-a + I` to install plugins
3. Open neovim - Lazy will auto-install plugins

## Theme

All tools use **Catppuccin Mocha** for consistent aesthetics.
