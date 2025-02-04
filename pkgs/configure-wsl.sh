#!/bin/bash

echo "*** Configuring WSL"

# Check if running on WSL
if ! grep -qi microsoft /proc/version; then
    echo "*** Not running on WSL, skipping configuration"
    exit 0
fi

# Get Windows username (with error handling)
WIN_USER=$(powershell.exe '$env:UserName' 2>/dev/null | tr -d '\r')
if [ -z "$WIN_USER" ]; then
    echo "** Error: Could not determine Windows username"
    exit 1
fi

# Path to .wslconfig
CONFIG_PATH="/mnt/c/Users/$WIN_USER/.wslconfig"

# Check if we have access to the Windows user directory
if [ ! -d "/mnt/c/Users/$WIN_USER" ]; then
    echo "** Error: Cannot access Windows user directory"
    exit 1
fi

# (Re)create new configuration file
echo "** Creating .wslconfig file"
rm -f "$CONFIG_PATH"
touch "$CONFIG_PATH"
echo "[wsl2]" >> "$CONFIG_PATH"
echo "networkingMode=mirrored" >> "$CONFIG_PATH"

echo "** WSL configuration completed successfully"
echo "** Please restart WSL for changes to take effect (run 'wsl --shutdown' in Windows)"
