#!/usr/bin/env bash
set -euo pipefail

function f_die() {
  echo "tmux-workspace-file-picker: $*" 1>&2
  exit 2
}

function f_pause() {
  local msg="$1"
  echo "$msg"
  read -r -n 1 -s -p "press any key to close"
  echo
}

function f_get_session_name() {
  tmux display-message -p "#{session_name}" 2>/dev/null || true
}

function f_get_option() {
  local session="$1"
  local opt="$2"
  tmux show-option -v -t "$session" "$opt" 2>/dev/null || true
}

function f_pick_files() {
  local root="$1"
  find "$root" -type d -name ".git" -prune -o \! -type d -print 2>/dev/null || true
}

function f_send_vim_cmd() {
  local pane="$1"
  local cmd="$2"
  tmux send-keys -t "$pane" Escape
  tmux send-keys -t "$pane" -l "$cmd"
  tmux send-keys -t "$pane" C-m
}

function f_main() {
  [[ -n "${TMUX:-}" ]] || f_die "run inside tmux"

  local session=""
  local root=""
  local vim_pane=""
  local fzf_out=""

  session="$(f_get_session_name)"
  if [[ -z "$session" ]]; then
    f_pause "unable to determine tmux session"
    return 1
  fi

  root="$(f_get_option "$session" "@workspace_root")"
  vim_pane="$(f_get_option "$session" "@workspace_vim_pane")"

  if [[ -z "$root" || -z "$vim_pane" ]]; then
    f_pause "workspace root or vim pane not set"
    return 1
  fi

  cd "$root"
  command -v fzf >/dev/null 2>&1 || f_die "fzf not found in PATH"
  fzf_out="$(f_pick_files "$root" | fzf -m --prompt "files> " --expect=enter)"
  if [[ -z "$fzf_out" ]]; then
    return 0
  fi

  local key=""
  local files=""
  key="$(printf '%s\n' "$fzf_out" | head -n 1)"
  files="$(printf '%s\n' "$fzf_out" | tail -n +2)"

  if [[ -z "$files" || "$key" != "enter" ]]; then
    return 0
  fi

  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    f_send_vim_cmd "$vim_pane" ":edit $f"
  done <<< "$files"

  # Bring focus to the vim pane
  tmux select-pane -t "$vim_pane"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  f_main "$@"
fi
