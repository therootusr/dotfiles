# Use p10k instead
# change zsh prompt to display if it's a VIM SHELL
#export PS1=%{$fg[magenta]%}$(env | grep -oh -m1 VIM | sed 's/\(.*\)/[\1SHELL] /')$PS1

# tmp to allow "set -o nounset"
KONSOLE_VERSION=""
# Set as zsh hook; otherwise certain stuff can misbehave (zsh theme / warp)
# set -o nounset

export LESS=-MiRW
export LC_ALL=en_US.UTF-8
export USR_LOG_DIR="$HOME/workspace/data/logs"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export GEMINI_API_KEY=AIzaSyAR-v41RZMR52J_9eiZMo6lN0htdhVrce8
export PATH="$HOME/.local/bin:$PATH"

# termcap settings for less to change highlight color.
export LESS_TERMCAP_so=$(echo -e '\e[48:5:13m') && export LESS_TERMCAP_se=$(echo -e '\e[0m')

export GOPATH=$HOME/.go
export PATH="$PATH:$GOPATH/bin"
# shouldn't GOBIN default to GOPATH/bin? Explore later!
# Apparently cursor wasn't picking it up (golang plugin in there)
export GOBIN=$HOME/.go/bin

# extended zsh_history
setopt extended_history
# add history immediately after typing a command
setopt inc_append_history

function _enable_nounset_after_init() {
  set -o nounset
}

preexec_functions+=(_enable_nounset_after_init)

function _disable_nounset_precmd() {
  set +o nounset
}

precmd_functions+=(_disable_nounset_precmd)

# iTerm2 Cmd+l shortcut is set to the following to allow unified scrollback
# wipe across tmux and non-tmux sessions (Cmd+l -> multi-action sequence):
#   Select Menu Item "Clear Buffer", then Send ^[[24~
# Tmux is configured to bind F12 to clear scrollback.
# Here, safely ignore F12 (\e[24~) sent by iTerm2 Cmd+l when outside of tmux.
# Without this, Zsh's vi-mode sees the Escape byte and drops into vicmd mode.
# We create a dummy widget that does nothing, and bind the key to it.
function _noop_widget() { true; }
zle -N _noop_widget
bindkey -M viins '\e[24~' _noop_widget
bindkey -M vicmd '\e[24~' _noop_widget
