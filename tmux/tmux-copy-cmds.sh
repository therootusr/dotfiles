#!/usr/bin/env bash
set -euo pipefail

# tmux-copy-cmds.sh — fzf picker (Alt+c): copy command(s) + output from a tmux
# pane's scrollback to the clipboard, reassembled in chronological order. The
# list shows just the commands, newest first (bare Enter = most recent one);
# TAB multi-selects; the preview shows the full block. Detection is regex on
# captured text (tmux exposes no OSC 133 marks to scripts); the shell-prompt-
# type table lives in the file named by $TMUX_COPY_SHELL_PROMPTS — start from
# tmux-copy-cmds.shell-prompts.example next to this script. Config problems
# (unset var, unreadable file, malformed row, bad ERE) abort with a message
# and exit 1: the file is the single source of truth, there is deliberately
# no built-in fallback table.
#
# The one knob: tmux option @copy-include-shell-prompt (prefix+p toggles it)
# = 1 keeps the prompt marker in copied text.
#
# Usage: tmux-copy-cmds.sh <pane_id> [scrollback_file]
#   (run inside display-popup -E; scrollback_file replaces capture-pane, for
#    headless tests)

die() {  # display-message expands #… formats; ## is a literal #
  tmux display-message "copy-cmds: ${1//'#'/##}"
  exit 1
}

INCLUDE="$(tmux show-option -gqv @copy-include-shell-prompt 2>/dev/null || true)"
BATCMD="$(command -v bat || command -v batcat || echo cat)"   # Debian: batcat
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PROMPTS="${TMUX_COPY_SHELL_PROMPTS:-}"
[[ -n "$PROMPTS" ]] || die "TMUX_COPY_SHELL_PROMPTS unset — cp tmux-copy-cmds.shell-prompts.example, point the var at it via ~/.zshenv or 'tmux set-environment -g' (see the example header)"
[[ -f "$PROMPTS" && -r "$PROMPTS" ]] || die "prompts file missing or unreadable: $PROMPTS"
# a bare-relative path named like identifier=… would be eaten as an awk
# assignment (silently, for NT=…), and -x as an option; ./ de-fangs both
[[ "$PROMPTS" == /* ]] || PROMPTS="./$PROMPTS"

WORKDIR="$(mktemp -d "${TMPDIR:-/tmp}/tmux-copy-cmds.XXXXXX")"
trap 'rm -rf "$WORKDIR"' EXIT

SB="${2:-}"
if [[ -z "$SB" ]]; then
  SB="$WORKDIR/scrollback"
  tmux capture-pane -t "${1:?usage: $0 <pane_id> [scrollback_file]}" -S - -E - -p >"$SB"
fi

# the prompts table rides in as awk's first input file (-v would escape-process
# the regexes); nonzero awk exit = config error, surfaced verbatim
if ! awk -f "$SCRIPT_DIR/tmux-copy-cmds.awk" \
    -v include_shell_prompt="${INCLUDE:-0}" -v dir="$WORKDIR" \
    "$PROMPTS" "$SB" >"$WORKDIR/manifest" 2>"$WORKDIR/awk-err"; then
  err="$(awk '{ s = s (NR > 1 ? " | " : "") $0 } END { printf "%s", substr(s, 1, 300) }' "$WORKDIR/awk-err")"
  die "${err:-prompt detection failed with no error output}"
fi

if [[ ! -s "$WORKDIR/manifest" ]]; then
  tmux display-message "No commands found in scrollback"; exit 0
fi

# newest first, so a bare Enter takes the most-recent command; fzf matches
# against the displayed field only (the --with-nth view)
selected="$(sort -t$'\t' -k1,1nr "$WORKDIR/manifest" | fzf \
  --multi --no-sort --delimiter=$'\t' --with-nth=2 \
  --layout=reverse --prompt='copy-cmds> ' --marker='✓ ' --pointer='▌' \
  --header='TAB multi-select · Enter copy (chronological) · ↑newest' \
  --preview "$BATCMD -l log --color=always --style=numbers --paging=never --line-range=:1000 {3} 2>/dev/null || cat {3}" \
  --preview-window='right,60%,wrap,border-left')" || true
[[ -z "$selected" ]] && exit 0

# reassemble picks in chronological (index) order, blank line between blocks
mapfile -t files < <(sort -t$'\t' -k1,1n <<<"$selected" | cut -f3)
result="$(awk 'FNR == 1 && NR > 1 { print "" } 1' "${files[@]}")"
# rcp (functions.zsh) loads a tmux buffer and writes the OSC 52 straight to
# each client tty -- `load-buffer -w` forward rides tmux's client output queue,
# which is discarded wholesale under backpressure, and these multi-command
# copies are the biggest payloads.
# rc!=0 = system clipboard not set (tmux buffer still is).
copy_rc=0
copy_err="$(printf '%s' "$result" | zsh -f -c "source '$SCRIPT_DIR/../shell/zsh/functions.zsh' && rcp" 2>&1)" || copy_rc=$?
if [[ $copy_rc -ne 0 ]]; then
  die "${copy_err:-clipboard copy failed with no error output (rc $copy_rc)}"
fi
n_lines="$(printf '%s\n' "$result" | wc -l | tr -d ' ')"
tmux display-message "Copied ${#files[@]} command(s), ${n_lines} line(s) to clipboard"
