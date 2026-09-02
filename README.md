# Dotfiles

This repository uses Ansible to bootstrap a personal macOS, Debian/Ubuntu, or
Fedora system and GNU Stow to link user configuration. A default run installs
only the command-line core. Desktop apps, servers, and other optional roles run
only when selected.

## Install the core setup

Clone the repository and run the bootstrap from its root:

```bash
git clone https://github.com/avilabss/.dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The script installs Ansible when needed and runs `ansible/site.yml`. Use another
mode to include optional roles or preview changes:

```bash
./bootstrap.sh --all                 # Core setup and every applicable optional role
./bootstrap.sh --tags docker,ssh     # Selected roles, plus the always-run common role
./bootstrap.sh --tags zsh            # Re-run Zsh, plus the common role
./bootstrap.sh --check               # Ansible dry run
```

`--all` removes the default `optional` skip. `--tags` passes the selected tags
to Ansible. The `common` role is tagged `always` and still runs.

## What it installs

### Core setup

| Area | Tools |
|---|---|
| Shell and terminal | Zsh, Oh My Zsh, Tmux, Starship, JetBrainsMono Nerd Font |
| Editor | [Neovim](docs/neovim.md) with LSP, debugging, Telescope, and Gitsigns/Fugitive Git workflows |
| Development | Git, Go, Rust, Node.js, Python, pipx, uv, and Poetry |
| Utilities | btop, ripgrep, fastfetch, GNU Stow, and platform essentials |

The core Ansible role tags are `common`, `fonts`, `zsh`, `tmux`, `starship`,
`dev-tools`, and `nvim`. They run during the default bootstrap.

### Optional tools

Optional roles are skipped unless you use `--all` or select their tag.

| Tag | Purpose | Platforms |
|---|---|---|
| `opencode` | OpenCode and this repository's agent configuration | All supported platforms |
| `openchamber` | OpenCode web/PWA workspace | All supported platforms |
| `ghostty` | Ghostty and its stowed configuration | All supported platforms |
| `google-chrome` or `chrome` | Google Chrome | All supported platforms |
| `zen` or `zen-browser` | Zen Browser | All supported platforms |
| `flameshot` | Screenshots | All supported platforms |
| `openwhispr` | Voice dictation and system-wide text insertion | Linux, x86_64 |
| `docker` | Docker on Linux or OrbStack on macOS | All supported platforms |
| `ssh` | OpenSSH server and firewall setup | Linux |
| `xrdp` | RDP server | Linux |
| `qemu` | QEMU guest agent | Linux |
| `sunshine` | Sunshine game-streaming server | All supported platforms |

Some configured packages are unavailable on certain distributions, releases,
or architectures. Where supported, bootstrap warns about the missing package,
skips it, and reports the failure without stopping the rest of the setup.

## User guides

- [Neovim](docs/neovim.md): first launch, language tooling, keymaps, plugin
  management, and troubleshooting.
- [OpenCode](docs/opencode.md): first authentication, the agent workflow,
  commands, skills, models, server helpers, and security boundaries.
- [Sunshine](docs/sunshine.md): unattended Fedora host setup with NVIDIA, KDE
  Plasma, Wayland, SDDM, and Moonlight.

## Platform packages

Package lists live in:

- macOS: `ansible/group_vars/macos.yml`
- Debian/Ubuntu: `ansible/group_vars/debian.yml`
- Fedora: `ansible/group_vars/fedora.yml`

## Set up OpenCode

Install OpenCode and stow its configuration:

```bash
./bootstrap.sh --tags opencode
```

Run `opencode`, enter `/connect`, choose **OpenAI (ChatGPT Plus/Pro)**, and
complete browser OAuth. Credentials stay outside this repository at
`~/.local/share/opencode/auth.json`.

Continue with the [OpenCode guide](docs/opencode.md) before starting an agent
workflow or exposing either server helper on the network.

## After installation

1. Restart the terminal, or run `source ~/.zshrc`, to load the linked shell
   configuration.
2. Open Neovim and allow lazy.nvim to install its locked plugins.

Tmux plugins are installed by bootstrap.

## Theme

Tracked tool configurations use Ayu Dark. KDE remains unmanaged by this
repository; its current setup uses the Dracula application theme with Tela Nord
Dark icons.
