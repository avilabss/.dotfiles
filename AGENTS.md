# Dotfiles maintainer guide

This guide is for contributors and coding agents changing the dotfiles
repository. Before editing, identify whether the change belongs in an Ansible
role, a platform variable file, or a stowed configuration directory. Run the
checks in [Mandatory checks](#mandatory-checks) before reporting completion.

The repository uses Ansible for system setup and package installation and GNU
Stow for configuration symlinks. It supports macOS, Debian/Ubuntu, and Fedora.
The entry point, `./bootstrap.sh`, installs Ansible when needed and then runs
`ansible/site.yml`.

## Architecture

```
bootstrap.sh        -> Installs Ansible and runs the playbook
ansible/site.yml    -> Classifies the platform and defines roles and tags
ansible/group_vars/ -> Shared and per-platform variables and package lists
ansible/roles/      -> One role per tool or feature
<tool>/             -> Stow package mirroring paths below the home directory
```

### Platform detection

The playbook uses `ansible.builtin.group_by` in `pre_tasks` to assign the host
to `macos`, `debian`, or `fedora`. Ansible then loads the matching
`ansible/group_vars/<platform>.yml`. Unsupported systems fail before roles run.

### Roles

Roles fall into two groups:

| Type | Roles | Behavior |
|---|---|---|
| Core | `common`, `fonts`, `zsh`, `tmux`, `starship`, `dev_tools`, `nvim` | Run during the default bootstrap |
| Optional | `opencode`, `openchamber`, `ghostty`, `google_chrome`, `zen_browser`, `flameshot`, `openwhispr`, `docker`, `ssh`, `xrdp`, `qemu`, `waydroid`, `sunshine` | Carry the `optional` tag and run only with `--all` or a selected role tag |

`openwhispr`, `ssh`, `xrdp`, and `qemu` are Linux-only. `waydroid` is
Fedora-only. The remaining optional roles are registered for every supported
platform. `zen_browser` uses the `zen` and `zen-browser` tags; the role names
and complete tag list are authoritative in `ansible/site.yml`.

Desktop app roles are optional so headless systems can keep the core setup
without pulling GUI packages. Ghostty stows its own configuration from its role
rather than through the default `stow_packages` list.

### Stow

The `common` role backs up paths listed in `stow_conflict_files` and stows each
default package in `stow_packages`. Both variables live in
`ansible/group_vars/all.yml`. Optional configuration roles outside that list,
including OpenCode, OpenChamber, and Ghostty, stow their own packages. Other
roles handle only tool-specific setup, such as installing Oh My Zsh or TPM.

### Tags

`bootstrap.sh` passes `--skip-tags optional` by default. `--all` removes that
skip. `--tags <name>` targets individual roles. The `common` role still runs
because it carries the `always` tag.

## Conventions

### Documentation

- Preserve each document's established structure, tone, audience, and level of
  detail.
- Put new information in the most relevant existing section instead of
  appending disconnected notes.
- Keep `README.md` focused on the project overview, primary setup and usage,
  and links to detailed guides.
- Keep detailed operational behavior in the relevant guide or authoritative
  workflow source.
- Avoid duplicating details across the README, guides, commands, skills, and
  other sources; link to the authoritative detail when useful.
- Make narrow, task-relevant edits instead of rewriting or reorganizing
  unrelated documentation.

### Ansible

- Always use fully qualified collection names, such as `ansible.builtin.apt`.
- Dispatch platform-specific work from `main.yml` to `macos.yml`,
  `debian.yml`, `fedora.yml`, or `linux.yml`.
- Put package lists in `ansible/group_vars/<platform>.yml`, not in tasks. Make GUI
  desktop apps optional roles when headless servers do not need them.
- Optional third-party repositories can disappear or omit a release or
  architecture. When an upstream repository cannot supply an optional package
  for the host, warn, add it to `dotfiles_failed_packages`, and continue the
  bootstrap.
- Prefer official package repositories with signature verification over
  convenience installer scripts. If only a script or community package source
  is configured, guard it by supported distribution, release, and architecture.
  Skip unsupported hosts with a warning.
- Put common variables in `ansible/group_vars/all.yml`.
- Use `become: true` for tasks requiring root on Linux. macOS Homebrew tasks do
  not use `become`.
- Set `environment: { PATH: "/opt/homebrew/bin:{{ ansible_env.PATH }}" }` for
  Homebrew commands in macOS tasks.
- Check whether a tool is already installed before installing it.

### Add a role

1. Create `ansible/roles/<name>/tasks/main.yml`
2. If per-platform logic is needed, create `macos.yml`, `debian.yml`, `fedora.yml` and dispatch from `main.yml`
3. Add any required variables to the appropriate `group_vars/` files
4. Register the role in `ansible/site.yml` with appropriate tags
5. If it's optional, add the `optional` tag alongside its name tag
6. If it's Linux-only, add `when: ansible_os_family != 'Darwin'`

### Add a stow package

1. Create a directory at the repository root that mirrors the home directory,
   such as `toolname/.config/toolname/config`.
2. Add the directory name to `stow_packages` in
   `ansible/group_vars/all.yml`.
3. If it creates files that conflict with stow, such as `.zshrc`, add them to
   `stow_conflict_files` in `ansible/group_vars/all.yml`.

### Add a platform

1. Create `ansible/group_vars/<platform>.yml` with package lists.
2. Add the distribution name to the `group_by` key in `ansible/site.yml`
   `pre_tasks`.
3. Add `<platform>.yml` task files to roles that need platform-specific logic.
   At minimum, update `common` and `dev_tools`.

### Add platform packages

- For macOS, edit `ansible/group_vars/macos.yml`. Use `common_packages` for
  Homebrew formulas, `brew_casks` for casks, `dev_tool_packages`, or
  `brew_taps`.
- For Debian/Ubuntu, edit `ansible/group_vars/debian.yml`. Use
  `common_packages` or `dev_tool_packages`.
- For Fedora, edit `ansible/group_vars/fedora.yml`. Use `common_packages` or
  `dev_tool_packages`.

## Mandatory checks

1. Update `README.md` when adding or removing a role or tool, or when changing
   top-level setup or usage.
2. Update `AGENTS.md` when conventions, patterns, or architecture change.
3. Register every new role in `ansible/site.yml` with the correct tags and
   platform condition.
4. Put package variables in the relevant `ansible/group_vars/` files.
5. Validate every changed YAML file; use spaces for indentation and preserve
   valid YAML structure.

## Theme

Use Ayu Dark for tracked tool configuration. KDE is the only exception: use
Nordic when no suitable Ayu theme is available.
