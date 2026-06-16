# Load ZSH configuration
zsh_dir=$HOME/.config/zsh
source $zsh_dir/dependencies.sh
# Sourced after dependencies.sh (which loads oh-my-zsh) so our aliases win
# over oh-my-zsh defaults (e.g. ll, which omz sets to 'ls -lh').
source $zsh_dir/aliases.sh
source $zsh_dir/environment.sh
source $zsh_dir/functions.sh
source $zsh_dir/notify.sh
[ -f $zsh_dir/secrets.sh ] && source $zsh_dir/secrets.sh

