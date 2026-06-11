#!/bin/bash

# Read JSON input
input=$(cat)

# Extract all values in a single jq call
eval "$(echo "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir)",
  @sh "model=\(.model.display_name)",
  @sh "session_name=\(.session_name // empty)",
  @sh "used_pct=\(.context_window.used_percentage // empty)",
  @sh "output_style=\(.output_style.name // empty)",
  @sh "total_cost=\(.cost.total_cost_usd // 0)"
')"

# Daily + monthly spend, recomputed from transcript token usage × model pricing
# (the authoritative method; the per-render cost field undercounts due to
# session-resume resets and cost-field lag). Cached for 60s to stay cheap.
daily_cost=""
monthly_cost=""
summary=$(python3 "$HOME/.claude/recompute_cost.py" --summary --cache 60 2>/dev/null)
if [ -n "$summary" ]; then
    eval "$(echo "$summary" | jq -r '
        @sh "daily_cost=\(.day // 0)",
        @sh "monthly_cost=\(.month // 0)"
    ')"
fi

# Get directory name
dir=$(basename "$cwd")

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

    git_info=$(printf "\033[33m%s%s%s\033[0m" "$branch" "$status" "$ahead_behind")
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

# Add cost (session / today / month)
cost_display=$(awk "BEGIN {printf \"%.2f\", $total_cost}")
daily_cost_display=$(awk "BEGIN {printf \"%.2f\", ${daily_cost:-0}}")
monthly_cost_display=$(awk "BEGIN {printf \"%.2f\", ${monthly_cost:-0}}")
if [ "$monthly_cost_display" != "0.00" ]; then
    parts+=("$(printf "\033[92m💰\$%s / \$%s / \$%s\033[0m" "$cost_display" "$daily_cost_display" "$monthly_cost_display")")
elif [ "$daily_cost_display" != "0.00" ]; then
    parts+=("$(printf "\033[92m💰\$%s / \$%s\033[0m" "$cost_display" "$daily_cost_display")")
elif [ "$cost_display" != "0.00" ]; then
    parts+=("$(printf "\033[92m💰\$%s\033[0m" "$cost_display")")
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
