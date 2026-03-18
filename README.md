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
./bootstrap.sh                       # Core setup
./bootstrap.sh --all                  # Everything (core + optional)
./bootstrap.sh --tags docker,ssh      # Specific optional roles
./bootstrap.sh --tags zsh             # Re-run a single role
./bootstrap.sh --check                # Dry run
```

## What Gets Installed

### Core

| Tool | Description |
|------|-------------|
| Neovim | Editor with LSP, completion, debugging, Telescope |
| Zsh | Shell with Oh My Zsh framework |
| Tmux | Terminal multiplexer with vim navigation |
| Starship | Cross-shell prompt |
| Ghostty | Terminal emulator |
| OpenCode | AI coding agent (config + agents) |
| Google Chrome | Browser |
| JetBrainsMono Nerd Font | Terminal font |
| fastfetch, ripgrep, flameshot | System info, search, screenshots |
| go, rust, node, python | Language runtimes |
| pipx, uv, poetry | Package managers |
| git, git-lfs | Version control |

### Optional (via tags)

| Tag | Description | Platforms |
|-----|-------------|-----------|
| `docker` | Docker / OrbStack | All |
| `ssh` | OpenSSH server + firewall | Linux |
| `xrdp` | Remote desktop (RDP) | Linux |
| `sunshine` | Remote desktop (Moonlight/Sunshine) | All |
| `qemu` | QEMU guest agent (Proxmox/KVM) | Linux |

## Adding Packages

Edit the `group_vars` file for your platform:

- **macOS:** `ansible/group_vars/macos.yml`
- **Debian/Ubuntu:** `ansible/group_vars/debian.yml`
- **Fedora:** `ansible/group_vars/fedora.yml`

## OpenCode

Config and agents are managed via stow (`opencode/.config/opencode/`).

### Provider Setup

After install, authenticate providers inside the OpenCode TUI:

```
/connect    # Select provider, follow prompts
/models     # Verify available models
```

Credentials are stored in `~/.local/share/opencode/auth.json` (not managed by dotfiles).

### Agents

| Agent | Model | Role |
|-------|-------|------|
| `architect` | `claude-opus-4-6` | Primary -- plans and delegates tasks |
| `developer` | `claude-sonnet-4-6` | Implements tasks from architect |
| `repo-scouter` | `claude-opus-4-6` | Scans repos for stack/conventions |
| `code-reviewer-1` | `gpt-5.3-codex` | Code review |
| `code-reviewer-2` | `claude-opus-4-6` | Code review |

All Anthropic models use max extended thinking. OpenAI codex uses high reasoning effort.

## Post-Install

1. Restart your terminal (or `source ~/.zshrc`)
2. In tmux, press `Ctrl-a + I` to install plugins
3. Open neovim - Lazy will auto-install plugins
4. Run `opencode`, then `/connect` to authenticate Anthropic and OpenAI

## Theme

All tools use **Catppuccin Mocha**.
