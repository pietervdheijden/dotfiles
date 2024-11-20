#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

SCRIPT_DIR=$(dirname "$(realpath "$0")")

if [[ ! -x "$(command -v pacman)" ]]; then
  echo "ERROR - script can only be executed on Arch Linux"
  exit 1 
fi

echo "*** Installing packages on Arch Linux"

echo "** Some dependencies need the administrator password:"
sudo -v

echo "*** Updating pacman..."
sudo pacman --noconfirm -Syu

echo "*** Installing software via pacman..."
sudo pacman --noconfirm -S stow
sudo pacman --noconfirm -S zsh
sudo pacman --noconfirm -S wget
sudo pacman --noconfirm -S vim
sudo pacman --noconfirm -S neovim
sudo pacman --noconfirm -S ripgrep
sudo pacman --noconfirm -S fd
sudo pacman --noconfirm -S luarocks
sudo pacman --noconfirm -S fzf
sudo pacman --noconfirm -S github-cli
sudo pacman --noconfirm -S zoxide
sudo pacman --noconfirm -S kubectl
sudo pacman --noconfirm -S tmux
sudo pacman --noconfirm -S lazygit
sudo pacman --noconfirm -S ttf-fira-code
sudo pacman --noconfirm -S man-db # manpath
sudo pacman --noconfirm -S git-delta
sudo pacman --noconfirm -S --needed git base-devel

# Install yay
if [[ ! -x "$(command -v yay)" ]]; then
  echo "*** Installing yay..."
  mkdir -p $HOME/tmp
  git clone https://aur.archlinux.org/yay.git $HOME/tmp/yay
  cd $HOME/tmp/yay
  makepkg -si
  cd -
  rm -rf $HOME/tmp/yay    
fi
  
echo "*** Installing AUR packages with yay..."
yay --noconfirm -S jdtls # Java Development Tools Language Server  
yay --noconfirm --needed -S terraform-ls # Terraform Language Server

# Install wslu on WSL
if [[ ! -x "$(command -v wslview)" ]] && grep -qi microsoft /proc/version; then
  echo "*** Installing wslu"
  mkdir -p $HOME/tmp
  wget https://pkg.wslutiliti.es/public.key -O $HOME/tmp/public.key
  sudo pacman-key --add $HOME/tmp/public.key
  rm $HOME/tmp/public.key
  sudo pacman-key --lsign-key 2D4C887EB08424F157151C493DD50AA7E055D853
  echo "[wslutilities]" | sudo tee -a /etc/pacman.conf
  echo "Server = https://pkg.wslutiliti.es/arch/" | sudo tee -a /etc/pacman.conf
  sudo pacman -Sy
  sudo pacman --noconfirm -S wslu 
fi


echo "[SUCCESS] Installed all Arch Linux packages!"
