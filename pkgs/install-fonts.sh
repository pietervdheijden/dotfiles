#!/usr/bin/env bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Determine fonts directory
if [[ $(uname -s) == MINGW* ]]; then
  # Windows
  fonts_directory="C:\Windows\Fonts"
elif [[ $(uname -s) == "Darwin" ]]; then
  # Mac OS
  fonts_directory=$HOME/Library/Fonts
else
  # Unix
  fonts_directory=$HOME/.fonts
fi

# Ensure fonts directory exists
mkdir -p $fonts_directory

# Copy fonts to fonts directory
cp $SCRIPT_DIR/fonts/* $fonts_directory
