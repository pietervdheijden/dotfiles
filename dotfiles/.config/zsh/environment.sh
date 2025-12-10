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
if [[ "$(uname -s)" == "Linux" ]] && grep -qi microsoft /proc/version 2>/dev/null; then
  # Use Windows browser (instead of WSL2 browser)
  export BROWSER=wslview

  # Set Chrome bin for npm tests
  export CHROME_BIN="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
fi

# Add go bin to PATH
export PATH=$PATH:~/go/bin

# Add home bin to PATH
export PATH=$PATH:~/bin

# Add pyenv bin to PATH
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Load cargo
. "$HOME/.cargo/env"

# libpq
if command -v brew >/dev/null 2>&1; then
  export PATH="$(brew --prefix libpq)/bin:$PATH"
  export PKG_CONFIG_PATH="$(brew --prefix libpq)/lib/pkgconfig:$PKG_CONFIG_PATH"
fi
