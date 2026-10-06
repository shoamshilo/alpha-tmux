#!/usr/bin/env bash
# Toggle Alpha capture on/off for the current tmux pane.

AL_BIN="${1:-al}"
TARGET_PANE=$(tmux display-message -p '#{pane_id}')

pane_off=$(tmux show-option -pqv -t "$TARGET_PANE" @alpha-pane-off 2>/dev/null)

if [ "$pane_off" = "1" ]; then
  # Re-enable capture
  tmux set-option -pqu -t "$TARGET_PANE" @alpha-pane-off
  tmux set-option -pqu -t "$TARGET_PANE" @alpha-injected
  tmux send-keys -t "$TARGET_PANE" " unset ALPHA_CAPTURE_OFF" Enter

  # Re-inject hooks (in case the shell lost them)
  CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  "$CURRENT_DIR/inject.sh" "$AL_BIN" "$TARGET_PANE"

  tmux display-message "Alpha capture: ON"
else
  # Disable capture — the hooks check ALPHA_CAPTURE_OFF and early-return
  tmux set-option -pq -t "$TARGET_PANE" @alpha-pane-off 1
  tmux send-keys -t "$TARGET_PANE" " export ALPHA_CAPTURE_OFF=1" Enter
  tmux display-message "Alpha capture: OFF"
fi
