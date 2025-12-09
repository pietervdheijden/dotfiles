#!/usr/bin/env bash
set -euo pipefail

echo "*** Configuring desktop (GNOME if available)"

# --- 1) Only continue on Linux ---
OS="$(uname -s)"
if [[ "$OS" != "Linux" ]]; then
  echo "*** Skipping GNOME configuration on $OS"
  exit 0
fi

# --- 2) Skip on WSL (Linux-only check) ---
if grep -qi microsoft /proc/version 2>/dev/null; then
  echo "*** Skipping GNOME configuration on WSL"
  exit 0
fi

# --- 3) Require gsettings (GNOME installed + session/dbus available) ---
if ! command -v gsettings >/dev/null 2>&1; then
  echo "*** Skipping GNOME configuration: gsettings not found"
  exit 0
fi

echo "*** Configuring GNOME"

# Rebind caps lock to ctrl
gsettings set org.gnome.desktop.input-sources xkb-options "['ctrl:nocaps']"

# Hide battery percentage (set to false)
gsettings set org.gnome.desktop.interface show-battery-percentage false
