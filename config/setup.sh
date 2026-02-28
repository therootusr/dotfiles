#!/bin/bash

set -euo pipefail

ZSHRC_PATH=${HOME}/.zshrc

IDEMPOTENTIFY_MARK="dotfiles_idempotent_append_to_main_zshrc.sh"

if [ ! -f $ZSHRC_PATH ]; then
  echo "FATAL: [EXIT] Missing zshrc: $ZSHRC_PATH" 1>&2
  exit 1
fi

set +e
grep_mark_res=$(grep --line-number --fixed-strings "$IDEMPOTENTIFY_MARK" "$ZSHRC_PATH")
grep_exit_code=$?
set -e

if [ $grep_exit_code -eq 0 ]; then
  zshrc_line_num="${ZSHRC_PATH}:$(echo $grep_mark_res | cut -d ':' -f 1)"
  echo "FATAL: '$ZSHRC_PATH' has already been modified" \
       "by this script: $0 (remove line $zshrc_line_num to force)."
  exit 0
fi

# Create symlinks
THIS_SCRIPT_PATH=$(realpath $0)
SRC_DOTFILES_DIR=$(dirname "$THIS_SCRIPT_PATH")

# TGT_DOTFILE_DIR="$HOME/.dotfiles"
# mkdir -v $TGT_DOTFILE_DIR

# ln -vs $SRC_DOTFILES_DIR/workman.basic.vimrc $TGT_DOTFILE_DIR/.ideavimrc
# ln -vs $SRC_DOTFILES_DIR/workman.vimrc $HOME/.vimrc

echo "INFO: creating '~/.ssh/cm_socket' if it doesn't exist"
mkdir -p ~/.ssh/cm_socket

echo "INFO: updating the global git config"
# Skip cp if file doesn't exist (set -e is in effect)
[[ -e ~/.gitconfig ]] && cp -v ~/.gitconfig ~/.gitconfig.backup.$IDEMPOTENTIFY_MARK.$(date +%s)
git config --global core.editor "vim -u $SRC_DOTFILES_DIR/workman.basic.vimrc -c 'set nomodeline'"
git config --global receive.denyCurrentBranch updateInstead
git config --global core.sshCommand "ssh -F $SRC_DOTFILES_DIR/ssh_config"
git config --global init.defaultBranch master
git config --global user.name "ps"
git config --global user.email "24826492+therootusr@users.noreply.github.com"

echo "INFO: saving existing zshrc"
cp -v $ZSHRC_PATH $ZSHRC_PATH.before.$IDEMPOTENTIFY_MARK.zshrc

echo "INFO: updating zshrc"

cat << EOT >> $ZSHRC_PATH

# Following 4 lines have been added by an external script.
# SCRIPT: $THIS_SCRIPT_PATH
# IDEMPOTENTIFY_MARK: $IDEMPOTENTIFY_MARK

[ ! -f $SRC_DOTFILES_DIR/one_include.commonrc ] || source $SRC_DOTFILES_DIR/one_include.commonrc
EOT
