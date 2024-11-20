#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

SCRIPT_DIR=$(dirname "$(realpath "$0")")

if [[ $(uname -s) == MINGW* ]]; then
  # Windows
  echo "Package installation on Windows is not supported yet."
elif [[ -x "$(command -v apt-get)" ]]; then
  $SCRIPT_DIR/ubuntu-install.sh
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

echo "[SUCCESS] Installed all packages!"
