#!/usr/bin/env bash

# search for all Git repos under ~/GitHub
dir=$(
  fd --type d               \
     --hidden               \
     --glob ".git"          \
     --exclude .git/objects \
     ~/GitHub               \
  | sed "s:/\.git/\$::"      \
  | fzf-tmux -p 80%,50%
)

# if a selection was made, open/switch in tmux
if [ -n "$dir" ]; then
  ~/.scripts/tmux-open-dir.sh "$dir"
fi

