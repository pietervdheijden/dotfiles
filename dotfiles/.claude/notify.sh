#!/bin/bash
TITLE="$1"
BODY="$2"
ICON="$HOME/.claude/claude-icon.png"

CLIENT_TTY=$(tmux display-message -p '#{client_tty}')
PANE_TTY=$(tmux display-message -t "$TMUX_PANE" -p '#{pane_tty}')

# Send notification directly to Kitty via client TTY
kitten notify --icon-path "$ICON" --only-print-escape-code "$TITLE" "$BODY" > "$CLIENT_TTY"

# Bell for audio notification
printf '\a' > "$PANE_TTY"

# Save pane ID for focus-on-click via tmux hook
echo "$TMUX_PANE" > /tmp/claude-notify-pane
(sleep 300 && rm -f /tmp/claude-notify-pane) &
