#!/usr/bin/env bash
set -euo pipefail

# Opens the full scrollback of a tmux pane in $EDITOR with line numbers.
# Intended to be run inside `tmux display-popup -E`.
# The popup auto-closes when the editor exits.
#
# Usage: tmux-open-scrollback.sh <pane_id>

die() { echo "$*"; read -r -n 1 -s -p "Press any key to close"; exit 1; }

pane_id="${1:?usage: $0 <pane_id>}"
file="$(mktemp /tmp/tmux-scrollback.XXXXXX)"
trap 'rm -f "$file"' EXIT

tmux capture-pane -t "$pane_id" -S - -E - -p > "$file" 2>&1 \
  || die "capture-pane failed for pane '$pane_id': $(cat "$file")"

[[ -s "$file" ]] || die "Scrollback is empty."

# Intentional word splitting: TMUX_EDITOR may contain args (e.g. "vim -u /path/to/vimrc")
# shellcheck disable=SC2086
${TMUX_EDITOR:-vim} '+set number' '+normal G' "$file"
