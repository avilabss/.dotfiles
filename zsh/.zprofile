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

# Keep user-installed npm packages out of system-owned directories. OpenChamber's
# built-in updater runs `npm install --global`, so it relies on this prefix too.
export NPM_CONFIG_PREFIX="$HOME/.local"

# Prefer user-local executables over system-wide versions.
export PATH="$HOME/.local/bin:$PATH"
