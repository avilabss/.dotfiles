# .dotfiles

Personal dotfiles for macOS and Linux, managed with GNU Stow.

## Quick Install

```bash
git clone https://github.com/avilabss/.dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

For automated installs (skip interactive prompts):
```bash
./install.sh --skip-optional
```

## What Gets Installed

### Core Tools (both platforms)

| Tool | Description |
|------|-------------|
| Neovim | Editor with LSP, completion, debugging, Telescope |
| Zsh | Shell with Oh My Zsh framework |
| Tmux | Terminal multiplexer with vim navigation |
| Starship | Cross-shell prompt |
| Ghostty | Terminal emulator |
| Docker | Containers (OrbStack on macOS) |
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

### Linux Optional Setup

When running on Linux, you'll be prompted to optionally install:
- **OpenSSH server** + UFW firewall
- **xrdp** for remote desktop
- **QEMU guest agent** (for Proxmox/KVM VMs)

Skip these prompts with `--skip-optional`.

## What the Install Script Does

1. **macOS**: Installs Homebrew (if needed), then runs `brew bundle`
2. **Linux**: Adds required PPAs, installs apt packages, then installs Docker/Starship/uv/Ghostty/Chrome/fonts via their official methods
3. **Both**: Installs Oh My Zsh + plugins, TPM, backs up existing dotfiles, stows configs, sets zsh as default shell

## Manual Installation

### 1. Install Dependencies

**macOS:**
```bash
brew bundle --file=Brewfile
```

**Linux (apt):**
```bash
# Add fastfetch PPA
sudo add-apt-repository ppa:zhangsongcui3371/fastfetch

# Install packages
sudo apt update
xargs -a packages/apt.txt sudo apt install -y

# Install tools not in apt
curl -fsSL https://get.docker.com | sh
curl -sS https://starship.rs/install.sh | sh
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 2. Install Oh My Zsh + Plugins

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 3. Install Tmux Plugin Manager

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### 4. Stow Configurations

```bash
cd ~/dotfiles
stow nvim zsh tmux starship ghostty
```

## Directory Structure

```
~/dotfiles/
├── install.sh              # Install script (run this)
├── Brewfile                # macOS dependencies
├── packages/
│   └── apt.txt             # Linux dependencies
├── nvim/.config/nvim/      # Neovim config
├── zsh/
│   ├── .zshrc              # Zsh config
│   └── .zprofile           # Zsh profile
├── tmux/.tmux.conf         # Tmux config
├── starship/.config/starship.toml
└── ghostty/.config/ghostty/
```

## Post-Install

1. Restart your terminal (or `source ~/.zshrc`)
2. In tmux, press `Ctrl-a + I` to install plugins
3. Open neovim - Lazy will auto-install plugins

## Adding Packages

**macOS:** Edit `Brewfile`, then run `brew bundle`

**Linux:** Edit `packages/apt.txt`, then run:
```bash
sudo apt update && xargs -a packages/apt.txt sudo apt install -y
```

## Theme

All tools use **Catppuccin Mocha** for consistent aesthetics.
