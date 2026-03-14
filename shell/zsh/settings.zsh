# Use p10k instead
# change zsh prompt to display if it's a VIM SHELL
#export PS1=%{$fg[magenta]%}$(env | grep -oh -m1 VIM | sed 's/\(.*\)/[\1SHELL] /')$PS1

# tmp to allow "set -o nounset"
KONSOLE_VERSION=""
# Set as zsh hook; otherwise certain stuff can misbehave (zsh theme / warp)
# set -o nounset

export LESS=-MiRWJ
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

## -------------- Redact hostname in right-prompt for security ----------------
# Partial redact: use: %3>>…%<< (truncate the remainder to length 3, from
# the right, with empty replacement).
#   e.g: POWERLEVEL9K_CONTEXT_REMOTE_TEMPLATE='%n@%3>>%m%<<'
# %M: to trunc the full hostname (incl. domain) instead of "up to first dot."

# local session doesn't print hostname on right prompt anyway
# typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@'

# when p10k on remote detects shell's in a remote session
typeset -g POWERLEVEL9K_CONTEXT_REMOTE_TEMPLATE='%n@'

# root isn't configured with p10k
# POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%n@'
# POWERLEVEL9K_CONTEXT_REMOTE_SUDO_TEMPLATE='%n@'

## ----------------------------------------------------------------------------
