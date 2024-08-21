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
)

# command for zsh-completions
autoload -U compinit && compinit

# Load Terraform CLI autocompletion.
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# Load Kubectl CLI autocompletion
source <(kubectl completion zsh)

# Oh My ZSH
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

# Load NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Zoxide
eval "$(zoxide init zsh)"

