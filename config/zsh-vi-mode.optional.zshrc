# Updates editor information when the keymap changes.
function zle-line-init zle-keymap-select {
  # update keymap variable for the prompt
  VI_KEYMAP=$KEYMAP

  zle reset-prompt
  zle -R
}

zle -N zle-keymap-select
zle -N zle-line-init
# zle -N edit-command-line

# 0.1s delay to register mode change.
export KEYTIMEOUT=1

# if mode indicator wasn't setup by theme, define default
# Work around possible set -o nounset
# update: comes from p10k
## mode=${MODE_INDICATOR:-}
## if [[ "$mode" == "" ]]; then
  ## MODE_INDICATOR="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
## fi

function vi_mode_prompt_info() {
  echo "${${VI_KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}

# update PROMPT
PROMPT='$(vi_mode_prompt_info)'$PROMPT
