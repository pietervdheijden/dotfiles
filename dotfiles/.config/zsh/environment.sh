# Vim
export EDITOR=nvim
export MANPAGER="nvim +Man!"

# Use UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Load global npm packages from home folder
NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin"
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

# WSL2 specific variables
if grep -qi microsoft /proc/version; then
  # Use Windows browser (instead of WSL2 browser)
  export BROWSER=wslview
fi

# Add go bin to PATH
export PATH=$PATH:~/go/bin

