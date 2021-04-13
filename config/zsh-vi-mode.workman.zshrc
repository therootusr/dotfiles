bindkey -v

# allow CTRL+v to edit the command line
# autoload -Uz edit-command-line
bindkey -M vicmd 'gv' edit-command-line

# allow ctrl-r and ctrl-s to search the history
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward

# workman key bindings
bindkey -M vicmd "n" vi-backward-char
bindkey -M vicmd "o" vi-forward-char
bindkey -M vicmd "h" vi-forward-word-end
bindkey -M vicmd "H" vi-forward-blank-word-end
bindkey -M vicmd "q" vi-backward-word
bindkey -M vicmd "Q" vi-backward-word-end
bindkey -M vicmd "gq" vi-backward-blank-word-end
bindkey -M vicmd "0" vi-first-non-blank
bindkey -M vicmd "^" vi-digit-or-beginning-of-line
bindkey -M vicmd "l" vi-open-line-below
bindkey -M vicmd "L" vi-open-line-above
bindkey -M vicmd "r" vi-replace-chars
bindkey -M vicmd "R" vi-replace
bindkey -M vicmd "k" undo
bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M vicmd "u" up-line-or-beginning-search
bindkey -M vicmd "e" down-line-or-beginning-search

bindkey "^[OA" up-line-or-beginning-search
bindkey "^[OB" down-line-or-beginning-search
bindkey "^[9876" backward-kill-word
bindkey "^[9875" beginning-of-line
bindkey "^[9874" end-of-line
# bind backspace key
bindkey "^?" backward-delete-char
