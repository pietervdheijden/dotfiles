#!/usr/bin/env bash

echo "*** Installing zsh dependencies"

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

# Determine fonts directory
if [[ $(uname -s) == MINGW* ]]; then
  # Windows
  fonts_directory="C:\Windows\Fonts"
elif [[ $(uname -s) == "Darwin" ]]; then
  # Mac OS
  fonts_directory=$HOME/Library/Fonts
else
  # Unix
  fonts_directory=$HOME/.fonts
fi

# Ensure fonts directory exists
mkdir -p $fonts_directory

# Download powerlevel10k fonts
# Source: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#fonts
download_font() {
  local name=$1
  local url=$2
  local target_folder=$3

  target_file=$target_folder/$name
  if [ ! -f "$target_file" ]; then
    echo "Downloading font: $name"
    wget -O "$target_file" $url
  fi
}
download_font "MesloLGS NF Regular.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf" $fonts_directory
download_font "MesloLGS NF Bold.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf" $fonts_directory
download_font "MesloLGS NF Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf" $fonts_directory
download_font "MesloLGS NF Bold Italic.ttf" "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf" $fonts_directory
