# Notify when long-running commands finish
# Uses preexec/precmd hooks to track command duration

# Minimum duration (seconds) before notifying
_NOTIFY_THRESHOLD=5

# Commands that are interactive/long-lived by nature — skip notifications
_NOTIFY_EXCLUDED=(vim nvim vi nano ssh less more man top htop watch tail tmux fzf)

preexec() {
    _notify_cmd="$1"
    _notify_start=$EPOCHSECONDS
}

precmd() {
    # Skip if no command was tracked
    [[ -z "$_notify_start" ]] && return

    local elapsed=$(( EPOCHSECONDS - _notify_start ))
    local cmd="$_notify_cmd"
    _notify_start=
    _notify_cmd=

    # Skip short commands
    (( elapsed < _NOTIFY_THRESHOLD )) && return

    # Skip excluded commands (match first word)
    local base="${cmd%% *}"
    base="${base##*/}"
    for exc in "${_NOTIFY_EXCLUDED[@]}"; do
        [[ "$base" == "$exc" ]] && return
    done

    # Only notify inside tmux
    [[ -z "$TMUX" ]] && return

    # Skip if this pane is focused and kitty has focus
    if [[ -n "$TMUX_PANE" ]] && [[ -f /tmp/tmux-kitty-focused ]]; then
        local active_pane
        active_pane=$(tmux display-message -p '#{pane_id}')
        [[ "$TMUX_PANE" == "$active_pane" ]] && return
    fi

    # Send notification
    tmux-notify "Command finished" "$cmd completed in ${elapsed}s"
}
