#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

SCRIPT_DIR=$(dirname "$(realpath "$0")")

if [[ ! -x "$(command -v apt-get)" ]]; then
  echo "ERROR - script can only be executed on Ubuntu"
  exit 1 
fi


echo "*** Installing packages on Ubuntu"

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
  $SCRIPT_DIR/arch-install.sh
fi

# Configure dynamic packages
echo "*** Configure dynamic packages"
$SCRIPT_DIR/configure-zsh.sh
$SCRIPT_DIR/configure-git.sh
$SCRIPT_DIR/configure-gnome.sh
$SCRIPT_DIR/configure-fonts.sh
$SCRIPT_DIR/configure-tmux.sh

echo "[SUCCESS] Installed all Ubuntu packages!"
