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
sudo pacman --noconfirm --needed -S stow
sudo pacman --noconfirm --needed -S zsh
sudo pacman --noconfirm --needed -S wget
sudo pacman --noconfirm --needed -S vim
sudo pacman --noconfirm --needed -S neovim
sudo pacman --noconfirm --needed -S ripgrep
sudo pacman --noconfirm --needed -S fd
sudo pacman --noconfirm --needed -S luarocks
sudo pacman --noconfirm --needed -S fzf
sudo pacman --noconfirm --needed -S github-cli
sudo pacman --noconfirm --needed -S zoxide
sudo pacman --noconfirm --needed -S kubectl
sudo pacman --noconfirm --needed -S tmux
sudo pacman --noconfirm --needed -S lazygit
sudo pacman --noconfirm --needed -S ttf-fira-code
sudo pacman --noconfirm --needed -S man-db # manpath
sudo pacman --noconfirm --needed -S git-delta
sudo pacman --noconfirm --needed -S --needed git base-devel
sudo pacman --noconfirm --needed -S azure-cli
sudo pacman --noconfirm --needed -S azure-kubelogin
sudo pacman --noconfirm --needed -S terraform
sudo pacman --noconfirm --needed -S openssh
sudo pacman --noconfirm --needed -S pyright # Python Language Server

# Install software using pacman when running on a native Linux host (not WSL2)
if ! grep -qi microsoft /proc/version; then
  sudo pacman --noconfirm --needed -S gnome
  sudo pacman --noconfirm --needed -S wl-clipboard
fi

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
yay --noconfirm --needed -S jdtls # Java Development Tools Language Server  
yay --noconfirm --needed -S terraform-ls # Terraform Language Server
yay --noconfirm --needed -S google-cloud-cli
yay --noconfirm --needed -S google-cloud-cli-gke-gcloud-auth-plugin

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
  sudo pacman --noconfirm --needed -S wslu 
fi


echo "[SUCCESS] Installed all Arch Linux packages!"
