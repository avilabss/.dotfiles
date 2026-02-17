#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_ALL=false
HAS_TAGS=false
EXTRA_ARGS=()

# Parse arguments
for arg in "$@"; do
    case $arg in
        --tags)  HAS_TAGS=true; EXTRA_ARGS+=("$arg") ;;
        --all)   INSTALL_ALL=true ;;
        --help|-h)
            echo "Usage: ./bootstrap.sh [OPTIONS] [ANSIBLE_ARGS]"
            echo ""
            echo "Options:"
            echo "  --all         Install everything including optional roles"
            echo "  --help, -h    Show this help message"
            echo ""
            echo "Examples:"
            echo "  ./bootstrap.sh                  Core setup only"
            echo "  ./bootstrap.sh --all            Everything (docker, ssh, xrdp, qemu, sunshine)"
            echo "  ./bootstrap.sh --tags docker    Only Docker"
            echo "  ./bootstrap.sh --check          Dry run"
            exit 0
            ;;
        *)      EXTRA_ARGS+=("$arg") ;;
    esac
done

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Dotfiles Bootstrap${NC}"
echo -e "${GREEN}========================================${NC}"

# Detect OS and install Ansible
if [[ "$OSTYPE" == darwin* ]]; then
    echo -e "${YELLOW}Detected macOS${NC}"

    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Install Ansible
    if ! command -v ansible &> /dev/null; then
        echo -e "${YELLOW}Installing Ansible...${NC}"
        brew install ansible
    fi

elif [[ "$OSTYPE" == linux* ]]; then
    echo -e "${YELLOW}Detected Linux${NC}"

    # Switch sudo-rs to legacy sudo wrapper if available (fixes Ansible become compatibility)
    if [[ -x /usr/bin/sudo.ws ]]; then
        echo -e "${YELLOW}Switching to legacy sudo for Ansible compatibility...${NC}"
        sudo update-alternatives --set sudo /usr/bin/sudo.ws
    fi

    if command -v apt &> /dev/null; then
        echo -e "${YELLOW}Detected Debian/Ubuntu - installing Ansible via apt...${NC}"
        sudo apt update
        sudo apt install -y ansible
    elif command -v dnf &> /dev/null; then
        echo -e "${YELLOW}Detected Fedora - installing Ansible via dnf...${NC}"
        sudo dnf install -y ansible
    else
        echo -e "${RED}Unsupported Linux distribution. Install Ansible manually, then run:${NC}"
        echo "  cd $DOTFILES_DIR/ansible && ansible-playbook site.yml"
        exit 1
    fi
else
    echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

echo -e "${GREEN}Ansible is ready. Running playbook...${NC}"

cd "$DOTFILES_DIR/ansible"

if [[ "$INSTALL_ALL" == true || "$HAS_TAGS" == true ]]; then
    ansible-playbook site.yml --ask-become-pass "${EXTRA_ARGS[@]}"
else
    ansible-playbook site.yml --ask-become-pass --skip-tags optional "${EXTRA_ARGS[@]}"
fi
