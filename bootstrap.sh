#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Run the playbook - pass any extra arguments through (e.g., --tags docker,ssh)
cd "$DOTFILES_DIR/ansible"
ansible-playbook site.yml "$@"
