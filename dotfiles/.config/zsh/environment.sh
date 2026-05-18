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

# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"

# Add pyenv bin to PATH
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init - --no-rehash)"
# `pyenv virtualenv-init` adds a chpwd hook that auto-activates a virtualenv
# when you cd into a directory with a `.python-version`. It costs ~70ms per
# shell start — uncomment if you rely on the auto-activate behavior.
# eval "$(pyenv virtualenv-init -)"

# Add dotnet to PATH
export PATH=$PATH:~/.dotnet

# Load cargo
. "$HOME/.cargo/env"

# libpq — hardcode the brew prefix so we don't spawn `brew --prefix` twice
# per shell (~60ms). Falls back to nothing if the path no longer exists.
if [[ -d /opt/homebrew/opt/libpq ]]; then
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
  export PKG_CONFIG_PATH="/opt/homebrew/opt/libpq/lib/pkgconfig:$PKG_CONFIG_PATH"
fi
