# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Disable Oh My Zsh theme (using Starship instead)
ZSH_THEME=""

# Which plugins would you like to load?
plugins=(
  git                      # git aliases and functions
  docker                   # docker completion and aliases
  docker-compose           # docker-compose aliases
  npm                      # npm completion
  node                     # node version info
  python                   # python aliases
  pip                      # pip completion
  extract                  # extract command for any archive
  sudo                     # press ESC twice to add sudo
  web-search               # google/duckduckgo from terminal
  zsh-autosuggestions      # fish-like autosuggestions (install separately)
  zsh-syntax-highlighting  # syntax highlighting (install separately)
)

source $ZSH/oh-my-zsh.sh

# User configuration

eval "$(starship init zsh)"

# Add VS Code to PATH
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
