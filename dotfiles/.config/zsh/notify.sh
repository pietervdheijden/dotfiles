# Notify when long-running commands finish
# Uses preexec/precmd hooks to track command duration

# Minimum duration (seconds) before notifying
_NOTIFY_THRESHOLD=5

# Commands that are interactive/long-lived by nature — skip notifications
_NOTIFY_EXCLUDED=(vim nvim vi nano ssh less more man top htop watch tail tmux fzf)

# True if the given macOS app bundle id is currently frontmost. When the
# terminal already has focus (e.g. you just quit an overlay like lazygit and
# your cursor is right there), a "command finished" alert is just noise.
# Falls back to "not focused" if lsappinfo is unavailable so we never go silent.
_notify_app_focused() {
    local front
    front=$(lsappinfo info -only bundleid "$(lsappinfo front 2>/dev/null)" 2>/dev/null) || return 1
    [[ "$front" == *"$1"* ]]
}

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
        # Ghostty (no tmux). Ghostty's `attention` bell self-suppresses while
        # focused, but `border`/`title` don't — so skip entirely when the
        # terminal already has focus (you're present, no need to alert).
        _notify_app_focused com.mitchellh.ghostty && return
        ghostty-notify "$title" "$body"
    fi
}
