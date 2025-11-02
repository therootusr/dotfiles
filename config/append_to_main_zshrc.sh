#!/bin/bash

ZSHRC_PATH=${HOME}/.zshrc

IDEMPOTENTIFY_MARK="dotfiles_idempotent_append_to_main_zshrc.sh"

if [ ! -f $ZSHRC_PATH ]; then
  echo "FATAL: [EXIT] Missing zshrc: $ZSHRC_PATH" 1>&2
  exit 1
fi

grep_mark_res=`grep --line-number --fixed-strings $IDEMPOTENTIFY_MARK $ZSHRC_PATH`
if [ $? == 0 ]; then
  zshrc_line_num="${ZSHRC_PATH}:$(echo $grep_mark_res | cut -d ':' -f 1)"
  echo "FATAL: '$ZSHRC_PATH' has already been modified" \
       "by this script (Remove line $zshrc_line_num to force)."
  exit 0
fi

# Create symlinks
SRC_DOTFILES_DIR=$(dirname "$(realpath "$0")")
# TGT_DOTFILE_DIR="$HOME/.dotfiles"
# mkdir -v $TGT_DOTFILE_DIR

# ln -vs $SRC_DOTFILES_DIR/workman.basic.vimrc $TGT_DOTFILE_DIR/.ideavimrc
# ln -vs $SRC_DOTFILES_DIR/workman.vimrc $HOME/.vimrc
# Shadow tmux cmd using a tmux alias that sources $SRC_DOTFILES_DIR/tmux.conf
# ln -vs $SRC_DOTFILES_DIR/tmux.conf $HOME/.tmux.conf

echo "Saving existing zshrc"
cp -v $ZSHRC_PATH $ZSHRC_PATH.before.$IDEMPOTENTIFY_MARK.zshrc

cat << EOT >> $ZSHRC_PATH

# Following 4 lines have been added by an external script.
# $IDEMPOTENTIFY_MARK

[ ! -f $SRC_DOTFILES_DIR/one_include.commonrc ] || source $SRC_DOTFILES_DIR/one_include.commonrc
EOT
