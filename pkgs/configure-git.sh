#!/usr/bin/env bash

# Keeping this as a shell script instead of a .gitconfig file
# so we can do some platform-specific things.

echo "*** Configuring git"

git config --global user.name "Pieter van der Heijden"

git config --global alias.ci "commit -v"
git config --global alias.co checkout
git config --global alias.cpick cherry-pick

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