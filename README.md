# Dotfiles

Personal macOS, Debian/Ubuntu, and Fedora setup managed with Ansible and GNU
Stow.

## Quick install

```bash
git clone https://github.com/avilabss/.dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The default run installs the core setup. Common alternatives are:

```bash
./bootstrap.sh --all                 # Core setup and every optional role
./bootstrap.sh --tags docker,ssh     # Selected optional roles
./bootstrap.sh --tags zsh            # Re-run one core role
./bootstrap.sh --check               # Ansible dry run
```

## What it installs

### Core setup

| Area | Tools |
|---|---|
| Shell and terminal | Zsh, Oh My Zsh, Tmux, Starship, JetBrainsMono Nerd Font |
| Editor | Neovim with LSP, completion, debugging, and Telescope |
| Development | Git, Go, Rust, Node.js, Python, pipx, uv, and Poetry |
| Utilities | btop, ripgrep, fastfetch, GNU Stow, and platform essentials |

The core Ansible role tags are `common`, `fonts`, `zsh`, `tmux`, `starship`,
`dev-tools`, and `nvim`.

### Optional tools

Optional roles are skipped unless you use `--all` or select their tag.

| Tag | Purpose | Platforms |
|---|---|---|
| `opencode` | OpenCode and this repository's agent configuration | All supported platforms |
| `openchamber` | OpenCode web/PWA workspace | All supported platforms |
| `ghostty` | Ghostty and its stowed configuration | All supported platforms |
| `google-chrome` or `chrome` | Google Chrome | All supported platforms |
| `flameshot` | Screenshots | All supported platforms |
| `openwhispr` | Voice dictation and system-wide text insertion | Linux, x86_64 |
| `docker` | Docker on Linux or OrbStack on macOS | All supported platforms |
| `ssh` | OpenSSH server and firewall setup | Linux |
| `xrdp` | RDP server | Linux |
| `qemu` | QEMU guest agent | Linux |
| `sunshine` | Sunshine game streaming server | All supported platforms |
| `waydroid` | Waydroid with Google apps and desktop launchers | Fedora |

Some distributions, releases, or architectures do not publish every configured
package. Where the role supports it, bootstrap prints a warning, skips the
unavailable package, and summarizes the failure instead of stopping the rest of
the setup.

## Platform packages

Package lists live in:

- macOS: `ansible/group_vars/macos.yml`
- Debian/Ubuntu: `ansible/group_vars/debian.yml`
- Fedora: `ansible/group_vars/fedora.yml`

## OpenCode

Install OpenCode and stow its configuration:

```bash
./bootstrap.sh --tags opencode
```

Run `opencode`, enter `/connect`, choose **OpenAI (ChatGPT Plus/Pro)**, and
complete browser OAuth. Credentials stay outside this repository at
`~/.local/share/opencode/auth.json`.

See the [OpenCode usage guide](opencode/.config/opencode/README.md) for the
agent workflow, commands, skills, models, and server helpers.

## After installation

1. Restart the terminal, or run `source ~/.zshrc`.
2. Open Neovim and let Lazy install its plugins.

Tmux plugins are installed by bootstrap.

## Theme

Tool configurations use **Catppuccin Mocha**.
