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

# NOTE: The configuration in this repository (specifically setup.sh, one_include.zsh,
# and aliases.zsh) currently assumes that the dotfiles directory path does not
# contain spaces. If the repo is cloned into a path with spaces, variable quoting
# will need to be updated across these files to prevent word-splitting issues.

ZSH_CONF_DIR="$(dirname "$(realpath "${0}")")"
export MY_DOTFILES_DIR=$(realpath "${ZSH_CONF_DIR}"/../..)

[ ! -f $ZSH_CONF_DIR/settings.zsh ] || source $ZSH_CONF_DIR/settings.zsh

[ ! -f $ZSH_CONF_DIR/aliases.zsh ] || source $ZSH_CONF_DIR/aliases.zsh

[ ! -f $ZSH_CONF_DIR/functions.zsh ] || source $ZSH_CONF_DIR/functions.zsh

[ ! -f $ZSH_CONF_DIR/warp.settings.zsh ] || source $ZSH_CONF_DIR/warp.settings.zsh

[ ! -f $ZSH_CONF_DIR/zsh-vi-mode.workman.zsh ] || source $ZSH_CONF_DIR/zsh-vi-mode.workman.zsh

# [ ! -f $ZSH_CONF_DIR/zsh-vi-mode.optional.zsh ] || source $ZSH_CONF_DIR/zsh-vi-mode.optional.zsh

# [ ! -f $ZSH_CONF_DIR/.fzf.zsh ] || source $ZSH_CONF_DIR/.fzf.zsh
