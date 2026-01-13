# .dotfiles

Personal dotfiles for macOS and Linux, managed with GNU Stow.

## Quick Install

```bash
git clone https://github.com/avilabss/.dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script will:
- Detect your OS (macOS or Linux)
- Install all dependencies (Homebrew on macOS, apt on Linux)
- Install Oh My Zsh and plugins
- Install Tmux Plugin Manager
- Stow all configurations
- Set zsh as default shell

## What's Included

| Tool | Description |
|------|-------------|
| **Neovim** | Editor with LSP, completion, debugging, Telescope |
| **Zsh** | Shell with Oh My Zsh framework |
| **Tmux** | Terminal multiplexer with vim navigation |
| **Starship** | Cross-shell prompt |
| **Ghostty** | Terminal emulator |

All tools use the **Catppuccin Mocha** theme.

## Manual Installation

If you prefer to install manually:

### 1. Install Dependencies

**macOS:**
```bash
brew bundle --file=Brewfile
```

**Linux (apt):**
```bash
# Install packages
xargs -a packages/apt.txt sudo apt install -y

# Install Starship
curl -sS https://starship.rs/install.sh | sh
```

### 2. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install plugins
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
├── install.sh          # Automated install script
├── Brewfile            # macOS dependencies (Homebrew)
├── packages/
│   └── apt.txt         # Linux dependencies (apt)
├── nvim/               # Neovim config
│   └── .config/nvim/
├── zsh/                # Zsh config
│   ├── .zshrc
│   └── .zprofile
├── tmux/               # Tmux config
│   └── .tmux.conf
├── starship/           # Starship prompt
│   └── .config/starship.toml
└── ghostty/            # Ghostty terminal
    └── .config/ghostty/
```

## Post-Install

1. Restart your terminal
2. In tmux, press `Ctrl-a + I` to install plugins
3. Open neovim - Lazy will auto-install plugins

## Adding/Removing Packages

**macOS:** Edit `Brewfile`, then run `brew bundle`

**Linux:** Edit `packages/apt.txt`, then run:
```bash
xargs -a packages/apt.txt sudo apt install -y
```
