# change zsh prompt to display if it's a VIM SHELL
export PS1=%{$fg[magenta]%}$(env | grep -oh -m1 VIM | sed 's/\(.*\)/[\1SHELL] /')$PS1

export LC_ALL=en_US.UTF-8
export USR_LOG_DIR="$HOME/workspace/data/logs"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

alias cdc='cd ~/workspace/misc/config'
alias cdg='cd ~/workspace/goal'
alias cdp='cd ~/workspace/playground'
alias cds='cd ~/workspace/misc/scripts'
alias clf='clang-format --style=file --fallback-style=google'

alias g4='g++ --std=c++14'
alias g7='g++ --std=c++17'
alias gs='git status'
alias glon='glo --numstat'
alias glop='glo -p'
alias gdcaw='git diff --cached --word-diff'
alias gdu='git diff @{upstream}'
alias gduw='git diff @{upstream} --word-diff'
alias grbom='git rebase origin/master'
alias grbu='git rebase @{upstream}'
alias grhhh='git reset --hard HEAD'
alias grhhu='git reset --hard @{upstream}'
alias grp='git rev-parse'

alias l='ls -Ahlrt'

alias python=python3

alias t='tmux'
alias ta='tmux a'
alias tls='tmux ls'
alias tks='tmux kill-server'
alias tree='tree -C'

alias v='vim'

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

    echo "cmd: ssh $1 \"tail -F $2\" 2>&1 > $USR_LOG_DIR/$log_file_name"
    ln -f -v -s $USR_LOG_DIR/$log_file_name $USR_LOG_DIR/$(basename $2)
    ssh $1 "tail -F $2" 2>&1 > $USR_LOG_DIR/$log_file_name
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

