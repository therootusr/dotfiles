#!/usr/bin/env bash
set -euo pipefail

# fzf-powered scrollback search. Selected lines are copied to the tmux paste
# buffer and synced to the system clipboard (via set-clipboard / OSC 52).
#
# Intended to be run inside `tmux display-popup -E`.
#
# Usage: tmux-fzf-scrollback.sh <pane_id>

pane_id="${1:?usage: $0 <pane_id>}"

scrollback="$(tmux capture-pane -t "$pane_id" -S - -E - -p)"
if [[ -z "$scrollback" ]]; then
  echo "Scrollback is empty."
  read -r -n 1 -s -p "Press any key to close"
  exit 0
fi

selected="$(printf '%s\n' "$scrollback" | \
  fzf --multi --no-sort --tac \
    --layout=reverse \
    --prompt='scrollback> ' \
    --header='TAB=multi-select  Enter=copy to clipboard')" || true

if [[ -n "${selected:-}" ]]; then
  printf '%s' "$selected" | tmux load-buffer -w -
  line_count="$(printf '%s\n' "$selected" | wc -l | tr -d ' ')"
  tmux display-message "Copied ${line_count} line(s) to clipboard"
fi
