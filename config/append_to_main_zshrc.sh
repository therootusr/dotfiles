#!/bin/bash

ZSHRC_PATH=${HOME}/.zshrc

IDEMPOTENTIFY_MARK="idempotent_append_to_main_zshrc.sh"

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
CONF_DIR="$HOME/workspace/misc/config/"
DOTFILE_DIR="$HOME/.dotfiles"
mkdir -v $DOTFILE_DIR

ln -vs $CONF_DIR/one_include.zshrc $DOTFILE_DIR/.one_include.zshrc
ln -vs $CONF_DIR/plug.zshrc $DOTFILE_DIR/.plug.zshrc
ln -vs $CONF_DIR/workman.basic.vimrc $DOTFILE_DIR/.basic.vimrc
ln -vs $CONF_DIR/workman.map.vimrc $DOTFILE_DIR/.map.vimrc
ln -vs $CONF_DIR/zsh-vi-mode.workman.zshrc $DOTFILE_DIR/.zsh-vi-mode.workman.zshrc
ln -vs $CONF_DIR/workman.basic.vimrc $DOTFILE_DIR/.ideavimrc
ln -vs $CONF_DIR/custom.plug.zshrc $DOTFILE_DIR/.tmp.zshrc
ln -vs $CONF_DIR/tmux.conf $DOTFILE_DIR/.tmux.conf
# ln -vs $CONF_DIR/zsh-vi-mode.optional.zshrc $DOTFILE_DIR/.zsh-vi-mode.optional.zshrc
# ln -vs $CONF_DIR/workman.vimrc $HOME/.vimrc
ln -vs $CONF_DIR/workman.basic.vimrc $HOME/.vimrc

echo "Saving existing zshrc"
cp -v $ZSHRC_PATH $ZSHRC_PATH.before_append_to_main_zshrc.old

cat << EOT >> $ZSHRC_PATH
# Following 4 lines have been added by an external script.
# idempotent_append_to_main_zshrc.sh

[ ! -f ~/.dotfiles/.one_include.zshrc ] || source ~/.dotfiles/.one_include.zshrc
EOT
