#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$SCRIPT_DIR/macos.Brewfile"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "ERROR - script can only be executed on MacOS"
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "ERROR - Homebrew is not installed. Install it first from https://brew.sh/"
  exit 1
fi

if [[ ! -f "$BREWFILE" ]]; then
  echo "ERROR - Brewfile not found at: $BREWFILE"
  exit 1
fi

echo "*** Installing packages on MacOS using $BREWFILE"

echo "==> Updating Homebrew..."
brew update

echo "==> Installing / upgrading from Brewfile..."
brew bundle install --file "$BREWFILE" --upgrade

echo "==> Cleaning up..."
brew cleanup

echo "==> Done!"
