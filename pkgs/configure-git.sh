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

# Core
git config --global core.editor vim

# Commit
REQUIRE_GPGSIGN=$(gpg --list-keys --with-colons | grep -q "Git" && echo "true" || echo "false")
git config --global commit.gpgsign $REQUIRE_GPGSIGN

# Push
git config --global push.autoSetupRemote true
git config --global push.default current

# Pull
git config --global pull.rebase false

# Advice
git config --global advice.addIgnoredFile false

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

# Let gh manage git credentials
gh auth setup-git
