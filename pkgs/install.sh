#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

SCRIPT_DIR=$(dirname "$(realpath "$0")")

if [[ $(uname -s) == MINGW* ]]; then
  # Windows
  echo "Package installation on Windows is not supported yet."
elif [[ -x "$(command -v apt-get)" ]]; then
  # Ubuntu
  # Install some packages with Homebrew, since Homebrew has more recent versions that apt-get

  # Install Homebrew
  if ! [ -x "$(command -v brew)" ]; then
    echo "*** Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    [ -d /home/linuxbrew/.linuxbrew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
  
  echo "*** Installing software with Homebrew..."
  brew install "neovim"
  brew install "jesseduffield/lazygit/lazygit"
  brew install "zoxide"
  brew install "openjdk@11"
  brew install "openjdk@17"
  brew install "hashicorp/tap/terraform-ls"
  brew install "git-delta"

  # Install packages with apt-get
  echo "*** Installing software via apt-get..."

  echo "** Some dependencies need the administrator password:"
  sudo -v

  sudo apt-get install -y stow
  sudo apt-get install -y zsh
  sudo apt-get install -y ripgrep
  sudo apt-get install -y fd-find
  sudo apt-get install -y luarocks
  sudo apt-get install -y fzf

  # Install Google Cloud SDK
  echo "*** Installing Google Cloud SDK..."
  if [ ! -f /usr/share/keyrings/cloud.google.gpg ]; then
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  fi
  sudo apt-get update
  sudo apt-get -y --no-upgrade install google-cloud-cli
  sudo apt-get -y --no-upgrade install google-cloud-sdk-gke-gcloud-auth-plugin

  # Install nvm
  if ! [ -x "$(command -v nvm)" ]; then
  echo "*** Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

  # Load NVM
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  fi
  nvm use node

  # NPM
  echo "*** Installing global npm packages..."
  npm install -g @angular/cli
  npm install -g neovim
  npm install -g pyright
elif [[ -x "$(command -v pacman)" ]]; then
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
  
  # Configure GNOME desktop environment settings
  # Skip configuration when running on WSL as it operates without a GUI
  if ! grep -qi microsoft /proc/version; then
    # Rebind caps lock to ctrl
    gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"
  fi
fi


# Configure dynamic packages
echo "*** Configure dynamic packages"
$SCRIPT_DIR/configure-zsh.sh
$SCRIPT_DIR/configure-git.sh
$SCRIPT_DIR/configure-fonts.sh
$SCRIPT_DIR/configure-tmux.sh

echo "[SUCCESS] Installed all packages!"
