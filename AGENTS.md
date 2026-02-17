# Dotfiles Project - Agent Guide

## Project Overview

Personal dotfiles repo managed with **Ansible** (system setup, package install) and **GNU Stow** (config symlinking). Supports **macOS**, **Debian/Ubuntu**, and **Fedora**.

Entry point: `./bootstrap.sh` installs Ansible, then runs `ansible/site.yml`.

## Architecture

```
bootstrap.sh          → Installs Ansible, runs playbook
ansible/site.yml      → Main playbook, defines roles and tags
ansible/group_vars/   → Per-platform package lists and variables
ansible/roles/        → One role per tool/feature
nvim/, zsh/, tmux/, starship/, ghostty/  → Stow directories (symlinked to ~)
```

### Platform Detection

The playbook auto-detects the OS via `group_by` in `pre_tasks` and assigns the host to one of: `macos`, `debian`, `fedora`. This triggers automatic loading of the matching `ansible/group_vars/<platform>.yml`.

### Roles

There are two kinds of roles:

- **Core roles**: Run by default (`common`, `fonts`, `dev_tools`, `zsh`, `nvim`, `tmux`, `starship`, `ghostty`)
- **Optional roles**: Tagged `optional`, skipped unless `--all` or `--tags <name>` is used (`docker`, `ssh`, `xrdp`, `qemu`, `sunshine`)

Some optional roles are Linux-only (restricted via `when: ansible_os_family != 'Darwin'` in `site.yml`).

### Stow

Stow is handled centrally in the `common` role — not in individual config roles. It backs up conflicting files, then runs `stow -R` for each package in the `stow_packages` list (`ansible/group_vars/all.yml`). Individual roles (zsh, tmux, etc.) only handle tool-specific setup like installing Oh My Zsh or TPM.

### Tags

`bootstrap.sh` passes `--skip-tags optional` by default. The `--all` flag removes that skip. Individual roles can be targeted with `--tags <name>`.

## Conventions

### Ansible

- Always use fully qualified collection names (e.g., `ansible.builtin.apt`, not `apt`)
- Per-platform task dispatch: `main.yml` includes platform-specific files (`macos.yml`, `debian.yml`, `fedora.yml`, or `linux.yml`)
- Package lists go in `ansible/group_vars/<platform>.yml`, not hardcoded in tasks
- Common/shared variables go in `ansible/group_vars/all.yml`
- Use `become: true` for tasks requiring root on Linux; macOS Homebrew tasks do NOT use become
- macOS tasks need `environment: { PATH: "/opt/homebrew/bin:{{ ansible_env.PATH }}" }` for brew commands
- Check if a tool is already installed before installing (idempotency)

### Adding a New Role

1. Create `ansible/roles/<name>/tasks/main.yml`
2. If per-platform logic is needed, create `macos.yml`, `debian.yml`, `fedora.yml` and dispatch from `main.yml`
3. Add any required variables to the appropriate `group_vars/` files
4. Register the role in `ansible/site.yml` with appropriate tags
5. If it's optional, add the `optional` tag alongside its name tag
6. If it's Linux-only, add `when: ansible_os_family != 'Darwin'`

### Adding a New Stow Package

1. Create a directory at the repo root mirroring the home directory structure (e.g., `toolname/.config/toolname/config`)
2. Add the directory name to `stow_packages` in `ansible/group_vars/all.yml`
3. If it creates files that conflict with stow (like `.zshrc`), add them to `stow_conflict_files` in `ansible/group_vars/all.yml`

### Adding a New Platform

1. Create `ansible/group_vars/<platform>.yml` with package lists
2. Add the distribution name to the `group_by` key in `ansible/site.yml` pre_tasks
3. Add `<platform>.yml` task files to roles that need platform-specific logic (at minimum: `common`, `dev_tools`)

### Adding Packages to an Existing Platform

- **macOS**: Edit `ansible/group_vars/macos.yml` — use `common_packages` (brew), `brew_casks` (cask), `dev_tool_packages`, or `brew_taps`
- **Debian/Ubuntu**: Edit `ansible/group_vars/debian.yml` — use `common_packages` or `dev_tool_packages`
- **Fedora**: Edit `ansible/group_vars/fedora.yml` — use `common_packages` or `dev_tool_packages`

## Mandatory Checks After Changes

1. **Update README.md** — if you add/remove a role, tool, or change usage, update the README tables and usage examples
2. **Update AGENTS.md** — if you change conventions, add new patterns, or alter the architecture, keep this file in sync
3. **Update site.yml** — if you add a new role, register it with proper tags
4. **Update group_vars** — if a new role needs packages, add variables to the relevant platform files
5. **YAML validity** — ensure all `.yml` files are valid YAML (no tab indentation, proper structure)

## Theme

All tools use **Catppuccin Mocha**. Any new tool config should use this theme for consistency.
