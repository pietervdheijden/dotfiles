#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Install + configure packages
read -r -p "*** Do you want to install packages? Press y if you do. " -n 1;
echo ""

if [[ $REPLY =~ ^[y]$ ]]; then
  $SCRIPT_DIR/pkgs/install.sh
else
  echo "** Skipping installation of packages..."
fi

# Create symlink for dotfiles
echo "*** Stowing dotfiles..."
stow -d $SCRIPT_DIR -t $HOME dotfiles
