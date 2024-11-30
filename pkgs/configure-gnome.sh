#!/usr/bin/env bash

# Configure GNOME desktop environment settings
# Skip configuration when running on WSL as it operates without a GUI
if grep -qi microsoft /proc/version; then
  echo "*** Skipping gnome configuration on WSL"
  exit
fi

echo "*** Configuring gnome"

# Rebind caps lock to ctrl
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"
gsettings set org.gnome.desktop.interface show-battery-percentage false

