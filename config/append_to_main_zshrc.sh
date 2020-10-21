#!/bin/bash

ZSHRC_PATH=${HOME}/.zshrc

IDEMPOTENTIFY_MARK="idempotent_append_to_main_zshrc.sh"

if [ ! -f $ZSHRC_PATH ]; then
  echo "FATAL: [EXIT] Missing zshrc: $ZSHRC_PATH" 1>&2
  exit 1
fi

grep_mark_res=`grep --line-number --fixed-strings \
    $IDEMPOTENTIFY_MARK $ZSHRC_PATH`
if [ $? == 0 ]; then
  echo "WARNING: [EXIT] zshrc: '$ZSHRC_PATH' has very likely already been" \
       "touched by this script (Remove line" \
       "${ZSHRC_PATH}:$(echo $grep_mark_res | cut -d ':' -f 1) to force)"
  exit 0
fi

# Create symlinks
ln -s $HOME/workspace/misc/config/plug.zshrc $HOME/.plug.zshrc
ln -s $HOME/workspace/misc/config/workman.basic.vimrc $HOME/.basic.vimrc
ln -s $HOME/workspace/misc/config/zsh-vi-mode.workman.zshrc $HOME/.zsh-vi-mode.workman.zshrc
ln -s $HOME/workspace/misc/config/workman.basic.vimrc $HOME/.ideavimrc
ln -s $HOME/workspace/misc/config/workman.vimrc $HOME/.vimrc
ln -s $HOME/workspace/misc/config/custom.plug.zshrc $HOME/.tmp.zshrc

cat << EOT >> $ZSHRC_PATH

# Following 29 lines have been added by an external script.
# idempotent_append_to_main_zshrc.sh

# Fail the command if any variable is unset.
set -o nounset

# With nounset there's the following error upon cd to a git repo
# parse_git_dirty:5: DISABLE_UNTRACKED_FILES_DIRTY: parameter not set
DISABLE_UNTRACKED_FILES_DIRTY=false

# Some unset complains potentially due to zsh-vi-mode
# TODO: Not aware about the full implications of this
VI_KEYMAP=${VI_KEYMAP:-}

if [ -f ~/.plug.zshrc ]; then
    source ~/.plug.zshrc
fi

if [ -f ~/.tmp.zshrc ]; then
    source ~/.tmp.zshrc
fi

if [ -f ~/.zsh-vi-mode.workman.zshrc ]; then
    source ~/.zsh-vi-mode.workman.zshrc
fi

EOT
