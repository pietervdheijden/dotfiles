#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Install Homebrew
if ! [ -x "$(command -v brew)" ]; then
  echo "*** Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install packages with Homebrew
echo "*** Installing software via Homebrew..."
brew bundle install --no-upgrade --file="$SCRIPT_DIR/Brewfile"

# Install 'packages' without package manager
$SCRIPT_DIR/install-zsh-deps.sh
