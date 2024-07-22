#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

## Install Homebrew
#if ! [ -x "$(command -v brew)" ]; then
#  echo "*** Installing Homebrew..."
#  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
#fi

if [[ $(uname -s) == MINGW* ]]; then
  # Windows
  echo "Package installation on Windows is not supported yet."
elif [[ $(uname -s) == "Darwin" ]]; then
  # Mac OS
  # Install packages with Homebrew
  echo "*** Installing software via Homebrew..."
  brew bundle install --no-upgrade --file="$SCRIPT_DIR/Brewfile"
else
  # Unix
  # Install packages with apt-get
  echo "*** Installing software via apt-get..."

  echo "** Some dependencies need the administrator password:"
  sudo -v

  sudo apt-get install stow -y
  sudo apt-get install zsh -y
fi


# Configure packages
$SCRIPT_DIR/configure-zsh.sh
$SCRIPT_DIR/configure-git.sh