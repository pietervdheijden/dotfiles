#!/bin/bash

# Note: on WSL2, the fonts should be manually downloaded and installed on Windows, and configured in the Windows Terminal

echo "*** Configuring fonts"

# Set variables
TMP_DIR=$HOME/tmp
FONT_DIR=$HOME/.local/share/fonts

# Download Meslo nerd font
if [ ! -f $FONT_DIR/MesloLGSNerdFont-Regular.ttf ]; then
  echo "** Install MesloLG Nerd Font"

  # Create the font directory if it doesn't exist
  mkdir -p $TMP_DIR

  # Download the font zip file
  wget -O $TMP_DIR/fonts.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Meslo.zip

  # Unzip
  unzip $TMP_DIR/fonts.zip -d $TMP_DIR/fonts

  # Move the font files to the fonts directory
  mv $TMP_DIR/fonts/*.ttf $FONT_DIR

  # Update the font cache
  fc-cache -fv

  # Clean up
  rm -rf $HOME/fonts $HOME/fonts.zip
fi

