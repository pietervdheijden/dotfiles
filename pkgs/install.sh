#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Install Homebrew
if ! [ -x "$(command -v brew)" ]; then
 echo "*** Installing Homebrew..."
 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
 [ -d /home/linuxbrew/.linuxbrew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [[ $(uname -s) == MINGW* ]]; then
  # Windows
  echo "Package installation on Windows is not supported yet."
elif [[ $(uname -s) == "Darwin" ]]; then
  # Mac OS
  # Install packages with Homebrew
  echo "*** Installing software via Homebrew..."
  brew bundle install --no-upgrade --file="$SCRIPT_DIR/MacOS.Brewfile"
else
  # Unix
  # Install packages with Homebrew
  # Required because Homebrew has more recent versions than apt-get
  echo "*** Installing software with Homebrew..."
  brew bundle install --no-upgrade --file="$SCRIPT_DIR/Ubuntu.Brewfile"

  # Install packages with apt-get
  echo "*** Installing software via apt-get..."

  echo "** Some dependencies need the administrator password:"
  sudo -v

  sudo apt-get install -y stow
  sudo apt-get install -y zsh
  sudo apt-get install -y ripgrep

  # Install Google Cloud SDK
  echo "*** Installing Google Cloud SDK..."
  if [ ! -f /usr/share/keyrings/cloud.google.gpg ]; then
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  fi
  sudo apt-get update
  sudo apt-get -y install google-cloud-cli
  sudo apt-get -y install google-cloud-sdk-gke-gcloud-auth-plugin

fi

# NPM
echo "*** Installing global npm packages..."
mkdir -p "${HOME}/.npm-packages"
npm config set prefix "${HOME}/.npm-packages" # Store global packages in home folder, so global *user* packages can be installed without sudo
npm install -g @angular/cli

# Configure packages
$SCRIPT_DIR/configure-zsh.sh
$SCRIPT_DIR/configure-git.sh
