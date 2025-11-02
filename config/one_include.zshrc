# With nounset there's the following error upon cd to a git repo
# parse_git_dirty:5: DISABLE_UNTRACKED_FILES_DIRTY: parameter not set
# DISABLE_UNTRACKED_FILES_DIRTY=false
#
# Some unset complains potentially due to zsh-vi-mode
# TODO: Not aware about the full implications of this
# VI_KEYMAP=${VI_KEYMAP:-}
#
# TODO: automate
# zshrc plugins: plugins=(git docker)

[ ! -f ~/.dotfiles/.fzf.zsh ] || source ~/.dotfiles/.fzf.zsh

[ ! -f ~/.dotfiles/.plug.zshrc ] || source ~/.dotfiles/.plug.zshrc

[ ! -f ~/.dotfiles/.tmp.zshrc ] || source ~/.dotfiles/.tmp.zshrc

[ ! -f ~/.dotfiles/.zsh-vi-mode.workman.zshrc ] || source ~/.dotfiles/.zsh-vi-mode.workman.zshrc

[ ! -f ~/.dotfiles/.zsh-vi-mode.optional.zshrc ] || source ~/.dotfiles/.zsh-vi-mode.optional.zshrc
