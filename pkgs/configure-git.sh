#!/usr/bin/env bash

# Keeping this as a shell script instead of a .gitconfig file
# so we can do some platform-specific things.

echo "*** Configuring git"

# User
git config --global user.name "Pieter van der Heijden"

# Alias
git config --global alias.ci "commit -v"
git config --global alias.co checkout
git config --global alias.cpick cherry-pick

# Push
git config --global push.autoSetupRemote true
git config --global push.default current

# Pull
git config --global pull.rebase false

# Platform specific configuration
if [[ $(uname -s) == MINGW* ]]; then
  # Windows
  git config --global core.autocrlf true
elif [[ $(uname -s) == "Darwin" ]]; then
  # Mac OS
  git config --global credential.helper osxkeychain
  git config --global core.autocrlf false
else
  # Unix
  git config --global credential.helper cache
  git config --global core.autocrlf false
fi