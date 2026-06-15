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
# Route personal repos through the github-personal SSH alias so they always
# authenticate as the personal account, regardless of the active gh account.
git config --file $PERSONAL_CONFIG_FILE url."git@github-personal:".insteadOf "https://github.com/"
git config --file $PERSONAL_CONFIG_FILE --add url."git@github-personal:".insteadOf "git@github.com:"
# Note, when using GPG signing, the following properties should be manually configured in the personal config file:
# git config --file $PERSONAL_CONFIG_FILE user.signingKey TODO
# git config --file $PERSONAL_CONFIG_FILE commit.gpgsign true
# git config --file $PERSONAL_CONFIG_FILE tag.gpgsign true

# Work config can be configured similarly to the personal config

# Personal SSH key + host alias, used by the url.insteadOf rewrite above so the
# github-personal alias presents the personal key for repos under ~/git/pietervdheijden/
PERSONAL_SSH_KEY=~/.ssh/id_ed25519_personal
if [[ ! -f $PERSONAL_SSH_KEY ]]; then
  echo "*** Generating personal SSH key"
  ssh-keygen -t ed25519 -f "$PERSONAL_SSH_KEY" -C "pietervdheijden personal" -N ""
fi

mkdir -p ~/.ssh
touch ~/.ssh/config
if ! grep -q "Host github-personal" ~/.ssh/config; then
  echo "*** Adding github-personal host alias to ~/.ssh/config"
  cat >> ~/.ssh/config <<'EOF'

Host github-personal
  HostName github.com
  AddKeysToAgent yes
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes
EOF
fi

# The personal public key must be uploaded to the personal GitHub account once.
# This is interactive (the token needs the admin:public_key scope), so it is not automated:
echo "*** Remember to upload the personal SSH key to your personal GitHub account:"
echo "    gh auth switch -u pietervdheijden && gh auth refresh -h github.com -s admin:public_key && gh ssh-key add ${PERSONAL_SSH_KEY}.pub --title \"$(scutil --get ComputerName 2>/dev/null || hostname -s)\""

# Let gh manage git credentials
gh auth setup-git
