#!/usr/bin/env bash
set -euo pipefail

# Copies the last executed command and its output to the tmux paste buffer
# and system clipboard. Uses configurable tmux options for prompt detection:
#
#   @prompt-pattern         grep regex matching the prompt marker (default: ^❯)
#   @prompt-preceding-lines number of decoration lines above the marker (default: 1)
#
# Prompt structure assumed (p10k example, @prompt-preceding-lines=1):
#
#   ~/path branch ··· user@ HH:MM:SS    ← decoration (1 preceding line)
#   ❯ command                            ← prompt marker (@prompt-pattern)
#   output line 1
#   output line 2
#   ~/path branch ··· user@ HH:MM:SS    ← next prompt's decoration
#   ❯                                   ← next prompt marker
#
# Usage: tmux-copy-last-cmd.sh <pane_id>

pane_id="${1:?usage: $0 <pane_id>}"
prompt_pattern="$(tmux show-option -gv @prompt-pattern 2>/dev/null)" || prompt_pattern='^❯'
preceding="$(tmux show-option -gv @prompt-preceding-lines 2>/dev/null)" || preceding=1

scrollback="$(tmux capture-pane -t "$pane_id" -S - -E - -p)"
if [[ -z "$scrollback" ]]; then
  tmux display-message "Empty scrollback"
  exit 0
fi

mapfile -t prompt_lines < <(printf '%s\n' "$scrollback" | grep -n "$prompt_pattern" | cut -d: -f1)

if [[ ${#prompt_lines[@]} -eq 0 ]]; then
  tmux display-message "No prompt markers found (pattern: $prompt_pattern)"
  exit 0
fi

if [[ ${#prompt_lines[@]} -eq 1 ]]; then
  cmd_line="${prompt_lines[0]}"
  result="$(printf '%s\n' "$scrollback" | tail -n +"$cmd_line")"
else
  cmd_line="${prompt_lines[-2]}"
  next_prompt_line="${prompt_lines[-1]}"
  end_line=$((next_prompt_line - preceding - 1))
  if [[ $end_line -lt $cmd_line ]]; then
    tmux display-message "@prompt-preceding-lines ($preceding) too large for gap between prompts at lines $cmd_line..$next_prompt_line"
    exit 1
  fi
  result="$(printf '%s\n' "$scrollback" | sed -n "${cmd_line},${end_line}p")"
fi

if [[ -z "$result" ]]; then
  tmux display-message "No command output found"
  exit 0
fi

printf '%s' "$result" | tmux load-buffer -w -
line_count="$(printf '%s\n' "$result" | wc -l | tr -d ' ')"
tmux display-message "Copied last command + output (${line_count} lines)"
