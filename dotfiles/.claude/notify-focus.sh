#!/bin/bash
f=/tmp/claude-notify-pane
[ -f "$f" ] || exit 0
p=$(cat "$f")
rm -f "$f"
tmux select-window -t "$p"
tmux select-pane -t "$p"
