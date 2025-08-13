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

# Personal config
PERSONAL_CONFIG_FILE=~/.gitconfig-pietervdheijden
git config --global 'includeIf.gitdir:~/git/pietervdheijden/.path' $PERSONAL_CONFIG_FILE
git config --file $PERSONAL_CONFIG_FILE user.email "pietervdheijden@gmail.com"
# Note, when using GPG signing, the following properties should be manually configured in the personal config file:
# git config --file $PERSONAL_CONFIG_FILE user.signingKey TODO
# git config --file $PERSONAL_CONFIG_FILE commit.gpgsign true
# git config --file $PERSONAL_CONFIG_FILE tag.gpgsign true

# Work config can be configured similarly to the personal config

# Let gh manage git credentials
gh auth setup-git
