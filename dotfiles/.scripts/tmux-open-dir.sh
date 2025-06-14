#!/usr/bin/env bash
# ~/bin/tmux-open-dir

dir="$1"
[ -n "$dir" ] || { echo "Usage: tmux-open-dir /path/to/dir"; exit 1; }

dir=$(realpath "$dir")
[ -d "$dir" ] || { echo "Invalid directory: $dir"; exit 1; }

found=""
while IFS= read -r line; do
  pane_id="${line%%:*}"
  pane_path="${line#*:}"
  if [[ "$pane_path" == "$dir" ]]; then
    found="$pane_id"
    break
  fi
done < <(tmux list-panes -a -F "#{pane_id}:#{pane_current_path}")

if [ -n "$found" ]; then
  tmux select-pane -t "$found"
  tmux select-window -t "$found"
else
  tmux new-window -c "$dir" -n "$(basename "$dir")"
fi

