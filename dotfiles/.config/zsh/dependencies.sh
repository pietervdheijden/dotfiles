# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -d /home/linuxbrew/.linuxbrew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Zsh configs
zstyle ':omz:update' mode auto      # update automatically without asking

# Plugins
# Set plugins before loading oh-my-zsh, otherwise plugins will not be used
plugins=(
    git
    sudo
    colored-man-pages
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
    kubectl
    helm
)

# Oh My ZSH
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
source $ZSH/oh-my-zsh.sh

# compinit is already run by oh-my-zsh.sh above — calling it again rebuilds
# .zcompdump and costs ~287ms per shell, so it stays commented out.
# autoload -U compinit && compinit

# Load Terraform CLI autocompletion.
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# Kubectl completion is already provided by the oh-my-zsh `kubectl` plugin
# (cached at ~/.oh-my-zsh/cache/completions/_kubectl). Sourcing
# `kubectl completion zsh` here regenerates it each shell start (~280ms).
# source <(kubectl completion zsh)

# Load p10k configuration
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

# Lazy-load NVM — sourcing nvm.sh costs ~400ms per shell, so defer it until
# the first call to nvm/node/npm/npx/corepack.
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  unset -f nvm node npm npx corepack
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
nvm()      { _load_nvm; nvm "$@"; }
node()     { _load_nvm; node "$@"; }
npm()      { _load_nvm; npm "$@"; }
npx()      { _load_nvm; npx "$@"; }
corepack() { _load_nvm; corepack "$@"; }

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

