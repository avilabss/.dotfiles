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
./bootstrap.sh --tags ghostty,google-chrome,flameshot,openwhispr  # Desktop apps only
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

## Adding Packages

Edit the `group_vars` file for your platform:

- **macOS:** `ansible/group_vars/macos.yml`
- **Debian/Ubuntu:** `ansible/group_vars/debian.yml`
- **Fedora:** `ansible/group_vars/fedora.yml`

## OpenCode

Config and agents are managed via stow (`opencode/.config/opencode/`). The opencode role handles stow separately from the common role, with the repository remaining the source of truth. Stow reports existing-file conflicts instead of adopting files into the repository.

### Provider Setup

One provider is used:

1. **OpenAI (ChatGPT Pro sub)** — powers architect, developer, repo-scouter, and both reviewers

```bash
# Auth OpenAI (ChatGPT Plus/Pro subscription)
/connect    # Select "OpenAI (ChatGPT Plus/Pro)", complete browser OAuth
```

Credentials are stored in `~/.local/share/opencode/auth.json` (not managed by dotfiles).

OpenCode is restricted to the configured OpenAI provider. Sol is the default model, while Luna handles lightweight internal work such as title generation. The OpenAI response-header timeout is 60 seconds to tolerate slow request starts without disabling stalled-request detection. Session sharing is disabled, snapshots remain enabled for undo support, old tool output is pruned during automatic context compaction, and common generated directories are excluded from file watching. Exa web search is enabled through `OPENCODE_ENABLE_EXA=1` for interactive, standalone-server, and OpenChamber sessions.

### Agents

| Agent | Model | Reasoning | Verbosity | Role |
|-------|-------|-----------|-----------|------|
| `architect` | `openai/gpt-5.6-sol` | high | medium | Highest-leverage planning and final decisions |
| `developer` | `openai/gpt-5.6-sol` | high | low | Careful implementation from an approved Task Brief |
| `repo-scouter` | `openai/gpt-5.6-sol` | high | medium | Builds foundational shared repository context |
| `code-reviewer-1` | `openai/gpt-5.6-sol` | high | low | Primary deep correctness and security review |
| `code-reviewer-2` | `openai/gpt-5.6-terra` | high | low | Independent second deep review pass |

Both reviewers run independently. The first uses Sol as the strongest quality gate; the second uses Terra for another deep pass without doubling Sol usage. `ARCHITECTURE.md` is the shared repository-context cache: agents read it first and invoke `repo-scouter` only when it is missing, stale, incomplete, or contradicted. Only `repo-scouter` updates it.

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

### Skills

The stowed OpenCode config includes `whitebox-review`, an architecture-aware
review skill for Whitebox.aero core, kernel, plugin, and cross-repository merge
requests. OpenChamber uses the same skill because its coding backend is
OpenCode and reads `~/.config/opencode/skills/`.

Use it in OpenCode by mentioning it explicitly in the prompt:

```text
Use $whitebox-review to review <merge-request-url>.
```

In OpenChamber, open the Whitebox repository workspace and send the same prompt
in chat:

```text
Use $whitebox-review to review <merge-request-url>.
```

The skill can also trigger from a direct request to review Whitebox code or a
Whitebox merge request. Explicit `$whitebox-review` invocation is preferable
when the current workspace or request does not make the Whitebox context clear.
After applying the dotfiles, restart OpenCode and OpenChamber so their OpenCode
processes reload the skill catalog.

## OpenCode Server Scripts

The `opencode` tag installs helper scripts for manually running the OpenCode server. No systemd or launchd service is created; the server runs only when you start it.

```bash
opencode-serve-start
opencode-serve-stop
opencode-db-vacuum
```

By default, `opencode-serve-start` runs `opencode serve` on `0.0.0.0:4096` in the background and writes logs to `~/.local/state/opencode/serve.log`. Both OpenCode and OpenChamber launchers warn when the OpenCode database reaches 1 GiB; stop both applications and run `opencode-db-vacuum` to integrity-check, checkpoint, and compact it. Override the warning threshold with `OPENCODE_DB_VACUUM_WARN_BYTES`.

Override the bind address or port per run with environment variables:

```bash
OPENCODE_SERVE_HOSTNAME=127.0.0.1 OPENCODE_SERVE_PORT=4096 opencode-serve-start
tail -f ~/.local/state/opencode/serve.log
```

> **Note:** Requires opencode to be installed first (`--tags opencode` or install manually).

## OpenChamber Server Scripts

The optional `openchamber` role installs the OpenChamber web/PWA interface and helper scripts. OpenChamber manages its own OpenCode process, so it can run independently of `opencode-serve-start`; both interfaces can also run at the same time.

```bash
openchamber-serve-start
openchamber-serve-stop
```

By default, OpenChamber listens on `0.0.0.0:4097`, runs its managed OpenCode child on port `4095`, and writes logs to `~/.local/state/openchamber/serve.log`. Before each launch, the helper rotates both that file and OpenCode's `~/.local/share/opencode/log/opencode.log` at 25 MiB, keeping three previous generations; override these defaults with `OPENCHAMBER_LOG_MAX_BYTES` and `OPENCHAMBER_LOG_KEEP`. The standalone `opencode-serve-start` helper continues using port `4096`, so both can run simultaneously while leaving common development ports such as `3000` free. Because OpenChamber exposes the UI to the network, set a password unless the network is fully trusted:

```bash
OPENCHAMBER_UI_PASSWORD='choose-a-strong-password' openchamber-serve-start
```

The bind address and port can be overridden per run:

```bash
OPENCHAMBER_SERVE_HOST=127.0.0.1 OPENCHAMBER_SERVE_PORT=4097 openchamber-serve-start
```

Set `OPENCODE_PORT` to override the managed OpenCode port. To connect OpenChamber to an already-running external OpenCode server instead, set `OPENCODE_HOST` and `OPENCODE_SKIP_START=true` as documented by OpenChamber.

> **Note:** The OpenChamber CLI requires Node.js 22 or newer and OpenCode. Install both roles with `./bootstrap.sh --tags opencode,openchamber`.

OpenChamber's built-in updater uses npm's global prefix. After applying these
dotfiles, start a new login shell (or run `source ~/.zprofile`) before using
`openchamber update`, so npm targets the user-writable `~/.local` prefix.

## Post-Install

1. Restart your terminal (or `source ~/.zshrc`)
2. Open neovim — Lazy will auto-install plugins
3. Run `opencode`, then `/connect` to authenticate OpenAI (ChatGPT Plus/Pro)

Tmux plugins, including the Catppuccin theme, are installed automatically by
the bootstrap. Terminal setup runs before development tools and Neovim so an
unrelated later failure does not leave the shell prompt or tmux theme missing.

## Theme

All tools use **Catppuccin Mocha**.
