#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_OPTIONAL=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --skip-optional) SKIP_OPTIONAL=true ;;
        --help|-h)
            echo "Usage: ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --skip-optional  Skip optional Linux setup (SSH, RDP, QEMU agent)"
            echo "  --help, -h       Show this help message"
            exit 0
            ;;
    esac
done

# OS Detection
case "$OSTYPE" in
    darwin*)  OS="macos" ;;
    linux*)   OS="linux" ;;
    *)        echo -e "${RED}Unsupported OS: $OSTYPE${NC}"; exit 1 ;;
esac

echo -e "${GREEN}Detected OS: $OS${NC}"

#------------------------------------------------------------------------------
# macOS Setup
#------------------------------------------------------------------------------
install_macos() {
    echo -e "${YELLOW}Setting up macOS...${NC}"

    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo -e "${GREEN}Homebrew already installed${NC}"
    fi

    # Install packages from Brewfile
    echo -e "${YELLOW}Installing packages from Brewfile...${NC}"
    brew bundle --file="$DOTFILES_DIR/Brewfile"
}

#------------------------------------------------------------------------------
# Linux Setup (apt-based)
#------------------------------------------------------------------------------
install_linux() {
    echo -e "${YELLOW}Setting up Linux...${NC}"

    # Check for apt
    if ! command -v apt &> /dev/null; then
        echo -e "${RED}apt not found. This script currently only supports apt-based distros.${NC}"
        exit 1
    fi

    # Add fastfetch PPA
    if ! grep -q "zhangsongcui3371/fastfetch" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        echo -e "${YELLOW}Adding fastfetch PPA...${NC}"
        sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    fi

    # Update package list
    echo -e "${YELLOW}Updating package list...${NC}"
    sudo apt update

    # Install packages from apt.txt
    echo -e "${YELLOW}Installing packages from apt.txt...${NC}"
    grep -v '^#' "$DOTFILES_DIR/packages/apt.txt" | grep -v '^$' | while read -r package; do
        if dpkg -l "$package" 2>/dev/null | grep -q "^ii"; then
            echo -e "${GREEN}$package already installed${NC}"
        else
            echo -e "${YELLOW}Installing $package...${NC}"
            sudo apt install -y "$package" || echo -e "${RED}Failed to install $package${NC}"
        fi
    done

    # Install Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}Installing Docker...${NC}"
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER"
        echo -e "${GREEN}Docker installed - log out and back in to use without sudo${NC}"
    else
        echo -e "${GREEN}Docker already installed${NC}"
    fi

    # Install Starship (not in apt)
    if ! command -v starship &> /dev/null; then
        echo -e "${YELLOW}Installing Starship...${NC}"
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    else
        echo -e "${GREEN}Starship already installed${NC}"
    fi

    # Install uv (not in apt)
    if ! command -v uv &> /dev/null; then
        echo -e "${YELLOW}Installing uv...${NC}"
        curl -LsSf https://astral.sh/uv/install.sh | sh
    else
        echo -e "${GREEN}uv already installed${NC}"
    fi

    # Install Ghostty (Ubuntu)
    if ! command -v ghostty &> /dev/null; then
        echo -e "${YELLOW}Installing Ghostty...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    else
        echo -e "${GREEN}Ghostty already installed${NC}"
    fi

    # Install Google Chrome
    if ! command -v google-chrome &> /dev/null; then
        echo -e "${YELLOW}Installing Google Chrome...${NC}"
        wget -q -O /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        sudo apt install -y /tmp/chrome.deb
        rm /tmp/chrome.deb
    else
        echo -e "${GREEN}Google Chrome already installed${NC}"
    fi

    # Install JetBrainsMono Nerd Font
    if ! fc-list | grep -qi "JetBrainsMono Nerd"; then
        echo -e "${YELLOW}Installing JetBrainsMono Nerd Font...${NC}"
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"
        wget -q -O /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -o -q /tmp/JetBrainsMono.zip -d "$FONT_DIR"
        rm /tmp/JetBrainsMono.zip
        fc-cache -f
    else
        echo -e "${GREEN}JetBrainsMono Nerd Font already installed${NC}"
    fi

    # Optional features
    if [[ "$SKIP_OPTIONAL" == false ]]; then
        install_linux_optional
    else
        echo -e "${YELLOW}Skipping optional setup (--skip-optional flag)${NC}"
    fi
}

#------------------------------------------------------------------------------
# Linux Optional Setup
#------------------------------------------------------------------------------
install_linux_optional() {
    echo ""
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  Optional Linux Setup${NC}"
    echo -e "${YELLOW}========================================${NC}"

    # SSH Server Setup
    read -p "Install and configure OpenSSH server? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installing OpenSSH server...${NC}"
        sudo apt install -y openssh-server

        echo -e "${YELLOW}Enabling SSH service...${NC}"
        sudo systemctl enable ssh
        sudo systemctl start ssh

        echo -e "${YELLOW}Configuring UFW for SSH...${NC}"
        sudo apt install -y ufw
        sudo ufw allow ssh
        sudo ufw --force enable

        echo -e "${GREEN}SSH server configured and UFW enabled${NC}"
    fi

    # RDP Setup
    read -p "Install and configure RDP (xrdp) for remote desktop? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installing xrdp...${NC}"
        sudo apt install -y xrdp

        echo -e "${YELLOW}Enabling xrdp service...${NC}"
        sudo systemctl enable xrdp
        sudo systemctl start xrdp

        # Allow RDP through firewall
        if command -v ufw &> /dev/null; then
            echo -e "${YELLOW}Configuring UFW for RDP (port 3389)...${NC}"
            sudo ufw allow 3389/tcp
        fi

        echo -e "${GREEN}RDP configured - connect using your IP on port 3389${NC}"
    fi

    # QEMU Guest Agent
    read -p "Install QEMU guest agent (for VMs running on Proxmox/KVM)? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installing QEMU guest agent...${NC}"
        sudo apt install -y qemu-guest-agent

        echo -e "${YELLOW}Enabling QEMU guest agent service...${NC}"
        sudo systemctl enable qemu-guest-agent
        sudo systemctl start qemu-guest-agent

        echo -e "${GREEN}QEMU guest agent configured${NC}"
    fi
}

#------------------------------------------------------------------------------
# Common Setup (both platforms)
#------------------------------------------------------------------------------
install_common() {
    # Install Oh My Zsh
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "${YELLOW}Installing Oh My Zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        echo -e "${GREEN}Oh My Zsh already installed${NC}"
    fi

    # Clone zsh plugins if not present (for oh-my-zsh custom plugins)
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        echo -e "${YELLOW}Installing zsh-autosuggestions plugin...${NC}"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        echo -e "${YELLOW}Installing zsh-syntax-highlighting plugin...${NC}"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    # Install TPM (Tmux Plugin Manager)
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        echo -e "${YELLOW}Installing Tmux Plugin Manager...${NC}"
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    else
        echo -e "${GREEN}TPM already installed${NC}"
    fi

    # Backup conflicting files before stowing
    echo -e "${YELLOW}Backing up existing dotfiles...${NC}"
    BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # Files that may conflict with stow
    CONFLICT_FILES=(.zshrc .zprofile .tmux.conf)
    for file in "${CONFLICT_FILES[@]}"; do
        if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
            echo -e "${YELLOW}Backing up $file...${NC}"
            mv "$HOME/$file" "$BACKUP_DIR/"
        fi
    done

    # Stow all configurations
    echo -e "${YELLOW}Stowing dotfiles...${NC}"
    cd "$DOTFILES_DIR"
    for dir in nvim zsh tmux starship ghostty; do
        if [[ -d "$dir" ]]; then
            echo -e "${YELLOW}Stowing $dir...${NC}"
            stow -R "$dir" || echo -e "${RED}Failed to stow $dir${NC}"
        fi
    done

    # Change default shell to zsh
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo -e "${YELLOW}Changing default shell to zsh...${NC}"
        chsh -s "$(which zsh)"
    fi

    echo -e "${GREEN}Done! Please restart your terminal or run: source ~/.zshrc${NC}"
}

#------------------------------------------------------------------------------
# Main
#------------------------------------------------------------------------------
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Dotfiles Installation Script${NC}"
    echo -e "${GREEN}========================================${NC}"

    if [[ "$OS" == "macos" ]]; then
        install_macos
    elif [[ "$OS" == "linux" ]]; then
        install_linux
    fi

    install_common

    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Restart your terminal"
    echo "  2. Run 'tmux' and press 'prefix + I' to install tmux plugins"
    echo "  3. Open neovim - plugins will auto-install via Lazy"
}

main "$@"
