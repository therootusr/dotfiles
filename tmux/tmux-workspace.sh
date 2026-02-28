#!/usr/bin/env bash

set -euo pipefail

function f_die() {
  echo "tmux-workspace: $*" 1>&2
  exit 2
}

function f_tmux() {
  if [[ -n "${TMUX_CONF:-}" ]]; then
    tmux -f "$TMUX_CONF" "$@"
  else
    tmux "$@"
  fi
}

function f_project_root_from_path() {
  local path="$1"
  realpath "$path"
}

function f_validate_session_name() {
  local name="$1"
  if [[ -z "$name" ]]; then
    f_die "session name is empty"
  fi
  if [[ "$name" == *:* || "$name" == *.* ]]; then
    f_die "session name contains invalid character (':' or '.')"
  fi
}

function f_attach_existing_window() {
  local session="$1"
  local ws_window="$2"
  local existing_core_session=""
  local windows=""

  windows="$(f_tmux list-windows -a -F $'#{session_name}\t#{window_name}' 2>/dev/null || true)"
  while IFS=$'\t' read -r window_session window_name; do
    [[ -z "$window_session" ]] && continue
    [[ "$window_session" == "$session" ]] || continue
    [[ "$window_name" == "$ws_window" ]] || continue
    existing_core_session="$window_session"
    break
  done <<< "$windows"

  if [[ -n "$existing_core_session" ]]; then
    if [[ -n "${TMUX:-}" ]]; then
      f_tmux switch-client -t "$existing_core_session:$ws_window"
    else
      f_tmux attach-session -t "$existing_core_session:$ws_window"
    fi
    return 0
  fi

  return 1
}

function f_setup_tmux_workspace() {
  local session="$1"
  local root="$2"
  local ws_window="$3"
  local editor="${EDITOR:-vim}"

  # Create base session + layout.
  if f_tmux has-session -t "$session" 2>/dev/null; then
    f_tmux new-window -t "$session" -c "$root" -n "$ws_window"
  else
    f_tmux new-session -d -s "$session" -c "$root" -n "$ws_window"
  fi

  local right_pane_id=""
  right_pane_id="$(f_tmux split-window -h -p 50 -P -F "#{pane_id}" -t "$session:$ws_window" -c "$root")"

  # Pane 3 (right): editor
  f_tmux send-keys -t "$right_pane_id" "$editor" C-m

  f_tmux set-option -t "$session" @workspace_root "$root"
  f_tmux set-option -t "$session" @workspace_vim_pane "$right_pane_id"
  f_tmux select-window -t "$session:$ws_window"
}

function f_main() {
  local root=""
  local session="${TMUX_WORKSPACE_SESSION:-}"

  if [[ $# -gt 1 ]]; then
    f_die "too many arguments (expected 0 or 1 path)"
  fi
  if [[ $# -eq 1 ]]; then
    root="$1"
  fi

  command -v tmux >/dev/null 2>&1 || f_die "tmux not found in PATH"

  if [[ -z "$root" ]]; then
    root="."
  fi
  root="$(f_project_root_from_path "$root")"
  [[ -d "$root" ]] || f_die "not a directory: $root"

  if [[ -z "$session" ]]; then
    session="$(basename "$root")"
  fi
  f_validate_session_name "$session"

  local ws_window="core"
  if f_attach_existing_window "$session" "$ws_window"; then
    return 0
  fi

  f_setup_tmux_workspace "$session" "$root" "$ws_window"

  if [[ -n "${TMUX:-}" ]]; then
    f_tmux switch-client -t "$session:$ws_window"
  else
    f_tmux attach-session -t "$session:$ws_window"
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  f_main "$@"
fi
