#!/usr/bin/env bash
# Status bar segment for tmux — shows "AL:on" or "AL:off".
# Usage in tmux.conf: set -g status-right '#(~/.tmux/plugins/alpha-tmux/scripts/status.sh)'

TARGET_PANE=$(tmux display-message -p '#{pane_id}')

global=$(tmux show-option -gqv @alpha-capture 2>/dev/null)
pane_off=$(tmux show-option -pqv -t "$TARGET_PANE" @alpha-pane-off 2>/dev/null)

if [ "$global" = "off" ] || [ "$pane_off" = "1" ]; then
  echo "#[fg=colour245]AL:off"
else
  echo "#[fg=colour34]AL:on"
fi
