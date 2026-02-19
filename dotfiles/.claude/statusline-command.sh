#!/bin/bash

# Read JSON input
input=$(cat)

# Extract values
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
model_id=$(echo "$input" | jq -r '.model.id')
session_name=$(echo "$input" | jq -r '.session_name // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

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

    git_info=$(printf "\033[33m(%s%s)\033[0m" "$branch" "$status")
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

# Add context remaining
if [ -n "$remaining" ]; then
    if awk "BEGIN {exit !($remaining < 20)}"; then
        color="\033[31m" # red
    elif awk "BEGIN {exit !($remaining < 50)}"; then
        color="\033[33m" # yellow
    else
        color="\033[32m" # green
    fi
    parts+=("$(printf "${color}ctx:%s%%\033[0m" "$remaining")")
fi

# Add output style if not default
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    parts+=("$(printf "\033[36m%s\033[0m" "$output_style")")
fi

# Add session duration
if [ -n "$duration" ]; then
    parts+=("$(printf "\033[95m%s\033[0m" "$duration")")
fi

# Add token usage and cost
if [ "$total_input" -gt 0 ] || [ "$total_output" -gt 0 ]; then
    # Calculate cost based on model
    # Prices per million tokens (as of January 2025)
    case "$model_id" in
        claude-opus-4*)
            input_price=15.00
            output_price=75.00
            ;;
        claude-sonnet-4*)
            input_price=3.00
            output_price=15.00
            ;;
        claude-3-5-sonnet*)
            input_price=3.00
            output_price=15.00
            ;;
        claude-3-5-haiku*)
            input_price=0.80
            output_price=4.00
            ;;
        claude-3-haiku*)
            input_price=0.25
            output_price=1.25
            ;;
        *)
            input_price=3.00
            output_price=15.00
            ;;
    esac

    # Calculate cost in dollars
    input_cost=$(awk "BEGIN {printf \"%.4f\", $total_input / 1000000 * $input_price}")
    output_cost=$(awk "BEGIN {printf \"%.4f\", $total_output / 1000000 * $output_price}")
    total_cost=$(awk "BEGIN {printf \"%.2f\", $input_cost + $output_cost}")

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
    parts+=("$(printf "\033[92m\$%s\033[0m" "$total_cost")")
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
