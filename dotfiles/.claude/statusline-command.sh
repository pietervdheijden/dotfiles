#!/bin/bash

# Read JSON input
input=$(cat)

# Extract values
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
session_name=$(echo "$input" | jq -r '.session_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

# Calculate turn count from transcript
turn_count=0
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    turn_count=$(grep -c '"type":"user"' "$transcript_path" 2>/dev/null || echo "0")
fi

# Get directory name
dir=$(basename "$cwd")

# Calculate session duration
duration=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Get file creation/modification time in seconds since epoch
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        file_time=$(stat -f %B "$transcript_path" 2>/dev/null)
    else
        # Linux
        file_time=$(stat -c %Y "$transcript_path" 2>/dev/null)
    fi

    if [ -n "$file_time" ]; then
        current_time=$(date +%s)
        duration_seconds=$((current_time - file_time))

        # Convert to human-readable format
        hours=$((duration_seconds / 3600))
        minutes=$(((duration_seconds % 3600) / 60))

        if [ $hours -gt 0 ]; then
            duration="${hours}h ${minutes}m"
        elif [ $minutes -gt 0 ]; then
            duration="${minutes}m"
        else
            duration="<1m"
        fi
    fi
fi

# Get git info
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo "detached")

    # Check for uncommitted changes
    if ! git -C "$cwd" diff-index --quiet HEAD -- 2>/dev/null; then
        status="*"
    else
        status=""
    fi

    # Get ahead/behind count relative to tracking branch
    ahead_behind=""
    if [ "$branch" != "detached" ]; then
        # Get the tracking branch
        tracking_branch=$(git -C "$cwd" for-each-ref --format='%(upstream:short)' "refs/heads/$branch" 2>/dev/null)

        if [ -n "$tracking_branch" ]; then
            # Count commits ahead and behind
            ahead=$(git -C "$cwd" rev-list --count "$tracking_branch..HEAD" 2>/dev/null || echo "0")
            behind=$(git -C "$cwd" rev-list --count "HEAD..$tracking_branch" 2>/dev/null || echo "0")

            # Build ahead/behind string
            if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
                ahead_behind=" ↑$ahead↓$behind"
            elif [ "$ahead" -gt 0 ]; then
                ahead_behind=" ↑$ahead"
            elif [ "$behind" -gt 0 ]; then
                ahead_behind=" ↓$behind"
            fi
        fi
    fi

    git_info=$(printf "\033[33m(%s%s%s)\033[0m" "$branch" "$status" "$ahead_behind")
fi

# Build status line parts
parts=()

# Add session name if set
if [ -n "$session_name" ]; then
    parts+=("$(printf "\033[35m[%s]\033[0m" "$session_name")")
fi

# Add directory
parts+=("$(printf "\033[34m%s\033[0m" "$dir")")

# Add git info
if [ -n "$git_info" ]; then
    parts+=("$git_info")
fi

# Add context usage
if [ -n "$used_pct" ]; then
    used_int=$(printf "%.0f" "$used_pct" 2>/dev/null || echo "0")
    if [ "$used_int" -ge 80 ]; then
        color="\033[31m" # red
    elif [ "$used_int" -ge 50 ]; then
        color="\033[33m" # yellow
    else
        color="\033[32m" # green
    fi
    parts+=("$(printf "${color}🧠%s%%\033[0m" "$used_int")")
fi

# Add output style if not default
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    parts+=("$(printf "\033[36m%s\033[0m" "$output_style")")
fi

# Add session duration
if [ -n "$duration" ]; then
    parts+=("$(printf "\033[95m%s\033[0m" "$duration")")
fi

# Add turn count
if [ "$turn_count" -gt 0 ]; then
    parts+=("$(printf "\033[94m💬%d\033[0m" "$turn_count")")
fi

# Add token usage
if [ "$total_input" -gt 0 ] || [ "$total_output" -gt 0 ]; then
    # Format tokens (K for thousands, M for millions)
    if [ "$total_input" -ge 1000000 ]; then
        input_display=$(awk "BEGIN {printf \"%.1fM\", $total_input / 1000000}")
    elif [ "$total_input" -ge 1000 ]; then
        input_display=$(awk "BEGIN {printf \"%.0fK\", $total_input / 1000}")
    else
        input_display="$total_input"
    fi

    if [ "$total_output" -ge 1000000 ]; then
        output_display=$(awk "BEGIN {printf \"%.1fM\", $total_output / 1000000}")
    elif [ "$total_output" -ge 1000 ]; then
        output_display=$(awk "BEGIN {printf \"%.0fK\", $total_output / 1000}")
    else
        output_display="$total_output"
    fi

    parts+=("$(printf "\033[96m↓%s ↑%s\033[0m" "$input_display" "$output_display")")
fi

# Add cost
cost_display=$(awk "BEGIN {printf \"%.2f\", $total_cost}")
if [ "$cost_display" != "0.00" ]; then
    parts+=("$(printf "\033[92m\$%s\033[0m" "$cost_display")")
fi

# Add model (shortened)
model_short=$(echo "$model" | sed 's/Claude //')
parts+=("$(printf "\033[90m%s\033[0m" "$model_short")")

# Join parts with separator
result=""
for i in "${!parts[@]}"; do
    if [ $i -gt 0 ]; then
        result+=" │ "
    fi
    result+="${parts[$i]}"
done

echo "$result"
