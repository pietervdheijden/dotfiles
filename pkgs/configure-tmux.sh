#!/bin/bash

echo "*** Configuring tmux"

# Install Tmux Plugin Manager
if [ ! -d $HOME/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
