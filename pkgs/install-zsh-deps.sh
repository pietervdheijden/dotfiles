#!/usr/bin/env bash

# Download GitHub repositories for zsh
get_gh_repository() {
  local repository=$1
  local target_folder=$2

  if [ ! -d $target_folder ]; then
    echo "Cloning ${repository}"
    git clone https://github.com/$repository.git $target_folder
  else
    echo "Updating ${repository}"
    git -C $target_folder pull
  fi
}
get_gh_repository ohmyzsh/ohmyzsh $HOME/.oh-my-zsh
get_gh_repository zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
get_gh_repository zsh-users/zsh-completions $HOME/.oh-my-zsh/custom/plugins/zsh-completions
get_gh_repository zsh-users/zsh-syntax-highlighting $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
get_gh_repository romkatv/powerlevel10k $HOME/.oh-my-zsh/custom/themes/powerlevel10k

# Change default shell to zsh
if [ $SHELL != "/bin/zsh" ]; then
  chsh -s $(which zsh)
fi
