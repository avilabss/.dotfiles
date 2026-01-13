#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

    # Update package list
    echo -e "${YELLOW}Updating package list...${NC}"
    sudo apt update

    # Install packages from apt.txt
    echo -e "${YELLOW}Installing packages from apt.txt...${NC}"
    grep -v '^#' "$DOTFILES_DIR/packages/apt.txt" | grep -v '^$' | while read -r package; do
        if dpkg -l "$package" &> /dev/null; then
            echo -e "${GREEN}$package already installed${NC}"
        else
            echo -e "${YELLOW}Installing $package...${NC}"
            sudo apt install -y "$package" || echo -e "${RED}Failed to install $package${NC}"
        fi
    done

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
