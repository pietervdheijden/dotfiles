# Load ZSH configuration
zsh_dir=$HOME/.config/zsh
source $zsh_dir/aliases.sh
source $zsh_dir/dependencies.sh
source $zsh_dir/environment.sh
source $zsh_dir/functions.sh
[ -f $zsh_dir/secrets.sh ] && source $zsh_dir/secrets.sh

