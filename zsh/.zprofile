# OS Detection
case "$OSTYPE" in
    darwin*)  IS_MACOS=true ;;
    linux*)   IS_LINUX=true ;;
esac

# Homebrew (macOS only)
if [[ $IS_MACOS ]] && [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# OrbStack: command-line tools and integration (macOS only)
if [[ $IS_MACOS ]]; then
    source ~/.orbstack/shell/init.zsh 2>/dev/null || :
fi

# Add local bin to PATH
export PATH="$PATH:$HOME/.local/bin"
