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
./bootstrap.sh --tags ghostty,google-chrome,flameshot  # Desktop apps only
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
| ripgrep | Fast search |
| fastfetch | System info summary; kept as core even where a distro package is unavailable |
| go, rust, node, python | Language runtimes |
| pipx, uv, poetry | Package managers |
| git, git-lfs | Version control |

### Optional (via tags)

| Tag | Description | Platforms |
|-----|-------------|-----------|
| `opencode` | AI coding agent (config + agents) | All |
| `ghostty` | Ghostty terminal emulator + stowed config | All |
| `google-chrome` / `chrome` | Google Chrome browser | All |
| `flameshot` | Screenshot tool | All |
| `docker` | Docker / OrbStack | All |
| `ssh` | OpenSSH server + firewall | Linux |
| `xrdp` | Remote desktop (RDP) | Linux |
| `sunshine` | Remote desktop (Moonlight/Sunshine) | All |
| `qemu` | QEMU guest agent (Proxmox/KVM) | Linux |

## Package Failures on Unsupported Hosts

Packages stay declared in dotfiles even when a host cannot install one of them. For example, `fastfetch` is part of the core package set, but some Raspberry Pi OS / Debian releases may not provide a package for it. Optional packages can hit the same case when an upstream repository does not publish a build for a specific release or architecture, such as Ghostty's COPR or Sunshine's release assets. In that case the bootstrap warns, skips that package on that host, and prints a failed-package summary at the end instead of removing it from the repo.

## Install Sources

- **Docker on Debian/Ubuntu:** Official Docker apt repository and signed packages; unsupported Debian-family derivatives skip with a warning.
- **Ghostty on Fedora:** `scottames/ghostty` COPR.
- **Ghostty on Ubuntu:** Community Ubuntu installer script; skipped with a warning on unsupported Debian-family distributions.
- **Sunshine on Ubuntu:** GitHub release `.deb` assets for configured Ubuntu releases and architectures; skipped with a warning otherwise.
- **Sunshine on Fedora:** LizardByte COPR with graceful skip behavior if the COPR is unavailable for the host.
- **Google Chrome on Fedora:** Google RPM with the Google Linux signing key imported; GPG checks remain enabled.

## Adding Packages

Edit the `group_vars` file for your platform:

- **macOS:** `ansible/group_vars/macos.yml`
- **Debian/Ubuntu:** `ansible/group_vars/debian.yml`
- **Fedora:** `ansible/group_vars/fedora.yml`

## OpenCode

Config and agents are managed via stow (`opencode/.config/opencode/`). The opencode role handles stow separately (not via the common role) using `stow --adopt` to safely merge any existing config.

### Provider Setup

One provider is used:

1. **OpenAI (ChatGPT Pro sub)** — powers architect, developer, repo-scouter, and both reviewers

```bash
# Auth OpenAI (ChatGPT Plus/Pro subscription)
/connect    # Select "OpenAI (ChatGPT Plus/Pro)", complete browser OAuth
```

Credentials are stored in `~/.local/share/opencode/auth.json` (not managed by dotfiles).

### Agents

| Agent | Model | Reasoning | Role |
|-------|-------|-----------|------|
| `architect` | `openai/gpt-5.5` | xhigh | Primary — plans and delegates tasks |
| `developer` | `openai/gpt-5.5` | xhigh | Implements tasks from architect |
| `repo-scouter` | `openai/gpt-5.5` | xhigh | Scans repos for stack/conventions |
| `code-reviewer-1` | `openai/gpt-5.5` | xhigh | Code review (latest GPT review pass) |
| `code-reviewer-2` | `openai/gpt-5.4` | xhigh | Code review (secondary GPT review pass) |

Both reviewers run independently on OpenAI GPT models, using different model families for review diversity.

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

## OpenCode Server Scripts

The `opencode` tag installs helper scripts for manually running the OpenCode server. No systemd or launchd service is created; the server runs only when you start it.

```bash
opencode-serve-start
opencode-serve-stop
```

By default, `opencode-serve-start` runs `opencode serve` on `0.0.0.0:4096` in the background and writes logs to `~/.local/state/opencode/serve.log`.

Override the bind address or port per run with environment variables:

```bash
OPENCODE_SERVE_HOSTNAME=127.0.0.1 OPENCODE_SERVE_PORT=4096 opencode-serve-start
tail -f ~/.local/state/opencode/serve.log
```

> **Note:** Requires opencode to be installed first (`--tags opencode` or install manually).

## Post-Install

1. Restart your terminal (or `source ~/.zshrc`)
2. In tmux, press `Ctrl-a + I` to install plugins
3. Open neovim — Lazy will auto-install plugins
4. Run `opencode`, then `/connect` to authenticate OpenAI (ChatGPT Plus/Pro)

## Theme

All tools use **Catppuccin Mocha**.
