# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

eval "$(starship init zsh)"

# Created by `pipx` on 2026-01-04 21:04:21
export PATH="$PATH:/Users/avi/.local/bin"

# Add VS Code to PATH
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
