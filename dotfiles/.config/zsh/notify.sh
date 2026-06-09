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

    local dir="${PWD##*/}"
    local title="Command finished ($dir)"
    local body="$cmd — ${elapsed}s"

    if [[ -n "$TMUX" ]]; then
        # tmux + kitty path (handles its own bell / focus detection)
        tmux-notify "$title" "$body"
    else
        # Ghostty (no tmux); Ghostty suppresses the alert while focused
        ghostty-notify "$title" "$body"
    fi
}
