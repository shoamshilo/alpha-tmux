#!/usr/bin/env bash
# Inject al shell hooks into a single tmux pane via send-keys.

AL_BIN="${1:-al}"
TARGET_PANE="${2:-}"

# Default to the active pane if none specified
if [ -z "$TARGET_PANE" ]; then
  TARGET_PANE=$(tmux display-message -p '#{pane_id}')
fi

# Skip if already injected
injected=$(tmux show-option -pqv -t "$TARGET_PANE" @alpha-injected 2>/dev/null)
[ "$injected" = "1" ] && exit 0

# Skip if per-pane capture is off
pane_off=$(tmux show-option -pqv -t "$TARGET_PANE" @alpha-pane-off 2>/dev/null)
[ "$pane_off" = "1" ] && exit 0

# Leading space keeps the eval out of shell history (HISTCONTROL=ignorespace / HIST_IGNORE_SPACE)
tmux send-keys -t "$TARGET_PANE" " eval \"\$($AL_BIN shell --init)\" 2>/dev/null" Enter

# Mark this pane as injected
tmux set-option -pq -t "$TARGET_PANE" @alpha-injected 1
