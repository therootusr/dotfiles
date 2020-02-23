# change zsh prompt to display if it's a VIM SHELL
export PS1=%{$fg[magenta]%}$(env | grep -oh -m1 VIM | sed 's/\(.*\)/[\1SHELL] /')$PS1

export LC_ALL=en_US.UTF-8
export USR_LOG_DIR="$HOME/workspace/data/logs"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# extended zsh_history
setopt extended_history
# add history immediately after typing a command
setopt inc_append_history

alias c='pbcopy'
alias ca='gcalcli agenda today tomorrow'
alias cal='gcalcli'
alias p='pbpaste'
alias cdc='cd ~/workspace/misc/config'
alias cdg='cd ~/workspace/goal'
alias cdp='cd ~/workspace/playground'
alias cds='cd ~/workspace/misc/scripts'
alias clf='clang-format --style=file --fallback-style=google'

alias g4='g++ --std=c++14'
alias g7='g++ --std=c++17'
alias gbvv='git branch -vv'
alias gg='git grep'
alias gs='git status'
alias glon='glo --numstat'
alias gdcaw='git diff --cached --word-diff'
alias gdu='git diff @{upstream}'
alias gduw='git diff @{upstream} --word-diff'
alias gfzf="git ls-files | fzf -m"
alias gls="git ls-files | fzf -m"
alias grbom='git rebase origin/master'
alias grbu='git rebase @{upstream}'
alias grhhh='git reset --hard HEAD~'
alias grhhu='git reset --hard @{upstream}'
alias grp='git rev-parse'
alias grph='git rev-parse HEAD'
alias gv='vim -u ~/.basic.vimrc `git ls-files | fzf -m`'
alias gvi='vim `git ls-files | fzf -m`'

alias l='ls -Ahlrt'

alias python=python3

alias sshu='ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null'

alias t='tmux'
alias ta='tmux a'
alias tls='tmux ls'
alias tks='tmux kill-server'
# Tree colored output MAC.
alias tree='tree -C'

alias v="vim -u ~/.basic.vimrc"
alias vz='vim `fzf -m`'

function fixup() {
  git reset --soft HEAD~$1
  git commit -v -a --amend --no-edit
}

# works with zsh; doesn't work with bash
function clang-format-git() {
  # is_git=$(git diff $1 &>/dev/null)
  # if [ $? -ne 0 ]; then
  #   echo "[ERROR] not a git repository"
  # fi

  git diff -U1 -- $1 | while read line ; do
    if [[ $line =~ "^@@.*\+([0-9]+),([0-9]+).*@@" ]];then
      from=$(($match[1] + 1))
      to=$(($match[1] + $match[2] - 2))
      clang-format -i --style=file --fallback-style=google --lines=$from:$to $1
    fi
  done
}

gpip(){
   PIP_REQUIRE_VIRTUALENV="0" pip3 "$@"
}

# Use command-t instead.
# Use alias 'gv' instead
function gvim() {
    file_path=$(git ls-files | grep -m1 -w $1)
    if [ -z $file_path ]; then
        echo "file not found"
        return 16
    fi

    echo $file_path
    vim $file_path
}

function swap() {
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE && mv "$2" "$1" && mv $TMPFILE "$2"
}

function tailRemoteFile() {
    if [ -z $1 ] || [ -z $2 ]; then
        echo "ERROR: Remote or Remote file path not provided"
        return 1
    fi

    log_file_name=$(basename $2)-${1/#*@/}
    if [ -e "$USR_LOG_DIR/$log_file_name" ]; then
        i=1
        while [ -e "$USR_LOG_DIR/$log_file_name-$i" ]; do
            let i++
        done
        log_file_name=$log_file_name-$i
    fi

    echo "cmd: ssh -o stricthostkeychecking=no $1 \"tail -F $2\" 2>&1 > $USR_LOG_DIR/$log_file_name"
    ln -f -v -s $USR_LOG_DIR/$log_file_name $USR_LOG_DIR/$(basename $2)
    ssh -o stricthostkeychecking=no $1 "tail -F $2" 2>&1 > $USR_LOG_DIR/$log_file_name
}

# Files receiving output from tailRemoteFile in logs dir (or a
# simple tail -F over ssh for that matter).
function get_remote_tail_files() {
  for pid in `pgrep -f "ssh.*tail.*-F"`
  do
    lsof -p $pid | grep "[^ ]*""$USR_LOG_DIR""[^ ]*" -o
  done
}

# Compliments tailRemoteFile (and "ssh -F" in general).
# All log files in $USR_LOG_DIR matching the regex specified by $1
# will be tailed.
# Optionally specify a filter regex in $2 to filter tail output.
# $3 is grep options for regex in $2.
function tailLocalFile() {
  if [ -z $1 ]; then
    echo "ERROR: Please provide regex to match files to be tailed as" \
         "the first argument."
    return 1
  fi

  filter_tail_out=""
  if [ "$2" != "" ]; then
    filter_tail_out=" | egrep $3 '(^=|$2)'"
  fi

  filepaths=`get_remote_tail_files | grep $1`
  echo "INFO: tail -F:\n$filepaths"
  echo ""
  # syntax issues without `echo | tr`
  /bin/sh -c "tail -F `echo $filepaths | tr '\n' ' '` $filter_tail_out"
}

# For macOS
function watch() {
    local sleep_dur=$1
    num_reg=^[0-9]+([.][0-9]+)?$
    if ! [[ $1 =~ $num_reg ]] ; then
       echo "Incorrect sleep duration: $1" >&2
       return 1
    fi
    shift
    while :; do clear; date; echo; $@; sleep $sleep_dur; done
}
