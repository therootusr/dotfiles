# bindkey -v (already being set by zsh-vi-mode.workman.zshrc)

# In zsh-vi insert mode: tab doesn't act as tmux-prefix.
# In zsh-vi cmd/viopp/visual mode: tab acts as tmux-prefix.

# unless overridden, viopp/visual mode inherit from vicmd mode -> tab = tmux-prefix
function _tmux_prefix_by_keymap() {
  if [[ $KEYMAP == viins ]]; then
    tmux set-option -p -q @pane_no_prefix 1   # pass Tab through
  else
    tmux set-option -p -q @pane_no_prefix 0   # Tab = tmux-prefix
  fi
}
zle -N zle-keymap-select _tmux_prefix_by_keymap

# since zsh starts in viins -> Tab shouldn't act as tmux prefix
# _tmux_prefix_by_keymap() is called by zle-keymap-select only after mode changes.
function _no_tmux_prefix_in_zsh_vi_insert_mode() {
    [[ -n $TMUX ]] && tmux set-option -p -q @pane_no_prefix 1
}
precmd_functions+=(_no_tmux_prefix_in_zsh_vi_insert_mode)
