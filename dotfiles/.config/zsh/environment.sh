# Vim
export EDITOR=nvim
export MANPAGER="nvim +Man!"

# Vi mode at the shell prompt (like Claude Code's editorMode=vim). Esc -> normal
# mode (hjkl, w/b, ciw, etc.), i/a -> insert. Sourced after oh-my-zsh so this
# wins over its default emacs bindings.
bindkey -v
# Make Esc register almost instantly instead of the default 0.4s delay.
export KEYTIMEOUT=1
# Keep a few emacs keys that are useful even in vi mode.
bindkey '^A' beginning-of-line          # Ctrl+A -> start of line
bindkey '^E' end-of-line                # Ctrl+E -> end of line
bindkey '^R' history-incremental-search-backward  # Ctrl+R -> history search
bindkey '^?' backward-delete-char       # Backspace deletes past insert point
bindkey -M vicmd '^R' history-incremental-search-backward

# Use UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Load global npm packages from home folder
NPM_PACKAGES="${HOME}/.npm-packages"
export PATH="$PATH:$NPM_PACKAGES/bin"
export MANPATH="${MANPATH-$(manpath)}:$NPM_PACKAGES/share/man"

# Put nvm's default Node on PATH without sourcing nvm.sh (~400ms). nvm is
# lazy-loaded in dependencies.sh via shell functions, but those only exist in
# the interactive shell — child processes (e.g. nvim's copilot.lua running
# `node --version`) inherit only PATH and otherwise find no `node` binary.
if [[ -d "$HOME/.nvm/versions/node" ]]; then
  # Read the `default` alias without forking cat; fall back to "node".
  _nvm_default="${$(<$HOME/.nvm/alias/default):-node}"
  if [[ "$_nvm_default" == v* ]]; then
    _nvm_node="$HOME/.nvm/versions/node/$_nvm_default"
  else
    # Newest installed version: glob dirs, (n) numeric-sorts, [-1] takes the last.
    _nvm_node=("$HOME"/.nvm/versions/node/v*(/Nn[-1]))
  fi
  [[ -x "$_nvm_node/bin/node" ]] && export PATH="$_nvm_node/bin:$PATH"
  unset _nvm_default _nvm_node
fi

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

# Merge all per-cluster kubeconfigs in ~/.kube/configs/ alongside the default.
# (N) expands to nothing when there are no matches, so KUBECONFIG stays clean.
typeset -a _kc=("$HOME/.kube/config" "$HOME"/.kube/configs/*.yaml(N))
export KUBECONFIG="${(j.:.)_kc}"
unset _kc

# libpq — hardcode the brew prefix so we don't spawn `brew --prefix` twice
# per shell (~60ms). Falls back to nothing if the path no longer exists.
if [[ -d /opt/homebrew/opt/libpq ]]; then
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
  export PKG_CONFIG_PATH="/opt/homebrew/opt/libpq/lib/pkgconfig:$PKG_CONFIG_PATH"
fi
