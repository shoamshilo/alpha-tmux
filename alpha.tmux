#!/usr/bin/env bash
# Alpha tmux plugin — TPM entry point
# Injects `al shell --init` capture hooks into every tmux pane automatically.

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# User-configurable tmux options (with defaults)
alpha_capture=$(tmux show-option -gqv @alpha-capture)
alpha_capture="${alpha_capture:-on}"

toggle_key=$(tmux show-option -gqv @alpha-key-toggle)
toggle_key="${toggle_key:-C}"

al_bin=$(tmux show-option -gqv @alpha-al-bin)
al_bin="${al_bin:-al}"

# Bail if globally disabled
if [ "$alpha_capture" != "on" ]; then
  exit 0
fi

# Check that the al binary exists
if ! command -v "$al_bin" >/dev/null 2>&1; then
  tmux display-message "alpha-tmux: '$al_bin' not found on PATH — capture disabled"
  exit 0
fi

# Register hooks for newly created panes
tmux set-hook -g after-new-session  "run-shell '\"$CURRENT_DIR/scripts/inject.sh\" \"$al_bin\"'"
tmux set-hook -g after-new-window   "run-shell '\"$CURRENT_DIR/scripts/inject.sh\" \"$al_bin\"'"
tmux set-hook -g after-split-window "run-shell '\"$CURRENT_DIR/scripts/inject.sh\" \"$al_bin\"'"

# Bind per-pane toggle key
tmux bind-key "$toggle_key" run-shell "\"$CURRENT_DIR/scripts/toggle.sh\" \"$al_bin\""

# Sweep: inject into all existing panes that are running a shell
SHELLS="bash zsh sh"
for pane_id in $(tmux list-panes -a -F '#{pane_id}'); do
  pane_cmd=$(tmux display-message -t "$pane_id" -p '#{pane_current_command}')
  for sh in $SHELLS; do
    if [ "$pane_cmd" = "$sh" ] || [ "$pane_cmd" = "-$sh" ]; then
      "$CURRENT_DIR/scripts/inject.sh" "$al_bin" "$pane_id" &
      break
    fi
  done
done

wait
