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
| Ghostty | Terminal emulator |
| Google Chrome | Browser |
| JetBrainsMono Nerd Font | Terminal font |
| fastfetch, ripgrep, flameshot | System info, search, screenshots |
| go, rust, node, python | Language runtimes |
| pipx, uv, poetry | Package managers |
| git, git-lfs | Version control |

### Optional (via tags)

| Tag | Description | Platforms |
|-----|-------------|-----------|
| `opencode` | AI coding agent (config + agents) | All |
| `opencode-serve` | OpenCode server as a persistent service | All |
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

Config and agents are managed via stow (`opencode/.config/opencode/`). The opencode role handles stow separately (not via the common role) using `stow --adopt` to safely merge any existing config.

### Provider Setup

After install, authenticate OpenRouter inside the OpenCode TUI:

```
/connect    # Select OpenRouter, enter API key
/models     # Verify available models
```

Credentials are stored in `~/.local/share/opencode/auth.json` (not managed by dotfiles). All models are routed through OpenRouter.

### Agents

| Agent | Model | Role |
|-------|-------|------|
| `architect` | `openrouter/anthropic/claude-opus-4-6` | Primary — plans and delegates tasks |
| `developer` | `openrouter/anthropic/claude-sonnet-4-6` | Implements tasks from architect |
| `repo-scouter` | `openrouter/anthropic/claude-opus-4-6` | Scans repos for stack/conventions |
| `code-reviewer-1` | `openrouter/openai/gpt-5.3-codex` | Code review (high reasoning) |
| `code-reviewer-2` | `openrouter/anthropic/claude-opus-4-6` | Code review |

All models routed through OpenRouter. Single API key for everything.

### Workflow

1. You describe what you want to `@architect` (the default agent)
2. Architect asks clarifying questions, then proposes a plan
3. You say "approved" to greenlight
4. Architect writes a Task Brief and delegates to `@developer`
5. Developer implements, then sends to both `@code-reviewer-1` and `@code-reviewer-2` in parallel
6. Reviewers approve or request changes — developer iterates until both approve
7. Everyone reports back to architect, who decides: done or another round
8. Architect summarizes and asks what's next

`@repo-scouter` can be called by any agent to scan the repo for stack, conventions, and commands.

**Key rules:** architect never writes code (only Task Briefs), developer never expands scope, reviewers can only read and request changes (no file edits).

## OpenCode Server

The `opencode-serve` tag sets up the OpenCode server as a persistent service that survives reboots.

```bash
./bootstrap.sh --tags opencode-serve
```

**What it does:**
- **Linux:** Creates a systemd user service (`opencode-serve`) + opens the firewall port (UFW/firewalld)
- **macOS:** Creates a launchd LaunchAgent (`com.opencode.serve`) — macOS prompts on first connection

**Configuration** (in `ansible/group_vars/all.yml`):

| Variable | Default | Description |
|----------|---------|-------------|
| `opencode_serve_port` | `4096` | Port for the server (matches `opencode.json` server config) |
| `opencode_serve_hostname` | `0.0.0.0` | Bind address (`0.0.0.0` = LAN accessible, `127.0.0.1` = local only) |
| `opencode_serve_password` | *(empty)* | Set `OPENCODE_SERVER_PASSWORD` for basic auth |

**Service management:**

```bash
# Linux
systemctl --user status opencode-serve
systemctl --user restart opencode-serve
journalctl --user -u opencode-serve -f

# macOS
launchctl list | grep opencode
launchctl kickstart -k gui/$(id -u)/com.opencode.serve  # restart
tail -f ~/Library/Logs/opencode-serve.log
```

> **Note:** Requires opencode to be installed first (`--tags opencode` or install manually).

## Post-Install

1. Restart your terminal (or `source ~/.zshrc`)
2. In tmux, press `Ctrl-a + I` to install plugins
3. Open neovim — Lazy will auto-install plugins
4. Run `opencode`, then `/connect` to authenticate OpenRouter

## Theme

All tools use **Catppuccin Mocha**.
