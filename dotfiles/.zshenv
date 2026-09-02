# Read dotfiles from ~/.config/zsh
export ZDOTDIR=$HOME/.config/zsh

# Disable global compinit, because it's very slow
skip_global_compinit=1

# lazygit (and other XDG-aware tools) default to ~/Library/Application Support
# on macOS, which leaves the versioned ~/.config copies unread. Point them at
# ~/.config so this repo is the single source of truth on every platform.
export XDG_CONFIG_HOME=$HOME/.config
