#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Install + configure packages
$SCRIPT_DIR/pkgs/install.sh

# Create symlink for dotfiles
echo "*** Stowing dotfiles..."
stow -d $SCRIPT_DIR -t $HOME dotfiles
