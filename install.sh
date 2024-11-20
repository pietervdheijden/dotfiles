#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Install + configure packages
read -r -p "*** Do you want to install packages? [Y/n] " -n 1;
echo ""

if [[ $REPLY =~ ^[Y]$ ]]; then
  $SCRIPT_DIR/pkgs/install.sh
else
  echo "** Skipping installation of packages..."
fi

# Create symlink for dotfiles
echo "*** Stowing dotfiles..."

# Create .config directory to prevent symlink on all subfolders
# Now only a symlink will be created on the folders in the dotfiles repository
# Otherwise, potentially sensitive configurations (like the gh folder) will be added to the Git repo
mkdir -p $HOME/.config
stow -d $SCRIPT_DIR -t $HOME dotfiles
