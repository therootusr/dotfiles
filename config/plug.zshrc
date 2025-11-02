# Use p10k instead
# change zsh prompt to display if it's a VIM SHELL
#export PS1=%{$fg[magenta]%}$(env | grep -oh -m1 VIM | sed 's/\(.*\)/[\1SHELL] /')$PS1

# Fail the command if any variable is unset.
set -o nounset

export LESS=-MiRW

export LC_ALL=en_US.UTF-8
export USR_LOG_DIR="$HOME/workspace/data/logs"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# termcap settings for less to change highlight color.
export LESS_TERMCAP_so=$(echo -e '\e[48:5:13m') && export LESS_TERMCAP_se=$(echo -e '\e[0m')

export GOPATH=$HOME/.go

# extended zsh_history
setopt extended_history
# add history immediately after typing a command
setopt inc_append_history

alias c='pbcopy'
alias ca='gcalcli agenda today tomorrow'
alias cal='gcalcli'
alias p='pbpaste'
alias cdb='cd ~/workspace/misc/bin'
alias cdc='cd ~/workspace/misc/config'
#alias cdg='cd ~/workspace/goal'
alias cdp='cd ~/workspace/playground'
alias cds='cd ~/workspace/misc/scripts'
alias cdt='cd ~/workspace/tmp'
alias clf='clang-format --style=file --fallback-style=google'

alias elw='elinks --dump-width 1000'

alias gbvv='git branch -vv'
alias gg='git grep'
alias gs='git status'
alias glon='glo --numstat'
alias glgu='glg @{upstream}'
alias glgf='glg --format=fuller'
alias glodf='git log --graph --pretty="%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(yellow)(%cd) %C(bold blue)<%an>%Creset"'
alias gdcaw='git diff --cached --word-diff'
alias gdu='git diff @{upstream}'
alias gduw='git diff @{upstream} --word-diff'
alias gfzf="git ls-files | fzf -m"
alias glsf="git ls-files"
alias glst="git ls-tree"
alias grbom='git rebase origin/master'
alias grbu='git rebase @{upstream}'
alias grhhh='git reset --hard HEAD~'
alias grhhu='git reset --hard @{upstream}'
alias grp='git rev-parse'
alias grph='git rev-parse HEAD'
alias gv='vim -u ~/.basic.vimrc `git ls-files | fzf -m`'
alias gvi='vim `git ls-files | fzf -m`'
alias gw='git worktree'
alias gcd='cd "$(git rev-parse --show-toplevel)"'

alias l='ls -Ahlrt'

# use symlinks instead
alias python=python3

alias tfo="terraform"

# ----------------------------------------------------------------------------------------------------
# docker
# ----------------------------------------------------------------------------------------------------
# using omz-plugin: docker; aliases don't feel very comprehensive
alias dk='docker'
# docker ps outdated; docker container ls = docker ps
# alias dkps='docker ps'
# alias dkpsa='docker ps -a'

alias db='docker build'

# builder appears to to be a synonym for buildx
# alias dkbld='docker builder'

alias dbx='docker buildx'
alias dbxpru='docker buildx prune'
alias dbxprua='docker buildx prune -a'

alias dctx='docker context'

alias dc="docker container"
alias dca="docker container attach"
alias dci="docker container inspect"
alias dcls="docker container ls"
alias dclsa="docker container ls -a"
alias dcpru="docker container prune"
alias dcr="docker container run"
alias dcrrm="docker container run --rm"
alias dcrit="docker container run -it"
alias dcritrm="docker container run -it --rm"
alias dcrm="docker container rm"
alias dcrmfv="docker container rm -f -v"
alias dcx="docker container exec"
alias dcxit="docker container exec -it"
alias dclogs="docker container logs"
alias dcrst="docker container restart"
alias dcst="docker container start"
alias dcstp="docker container stop"
alias dcstpf="docker container stop -s SIGKILL"
alias dcstpa="docker stop \$(docker ps -q)"
alias dctop="docker top"

alias di="docker image"
alias dib="docker image build"
alias dii="docker image inspect"
alias dils="docker image list"
alias dilsa="docker image list -a"
alias dipush="docker image push"
alias dirm="docker image rm"
alias dit="docker image tag"
alias dipull="docker image pull"
alias dipru="docker image prune"
alias diprua="docker image prune -a"

alias dn="docker network"
alias dnc="docker network create"
alias dnco="docker network connect"
alias dncdcn="docker network disconnect"
alias dni="docker network inspect"
alias dnls="docker network ls"
alias dnrm="docker network rm"


alias dv="docker volume"
alias dvi="docker volume inspect"
alias dvls="docker volume ls"
alias dvrm="docker volume rm"
alias dvpru="docker volume prune"
alias dvprua="docker volume prune -a"

alias f_dcup='f_dc up'
alias f_dcps='f_dc ps'
# alias da='docker attach'
# alias dinfo='docker info'
# alias dstats='docker stats'

# docker compose

alias dkc='docker compose'
alias dkcb="docker compose build"
alias dkcup='docker compose up'
alias dkcupb='docker compose up --build'
alias dkcupbf='docker compose up --build --force-recreate'
alias dkcd="docker compose down"
alias dkcdv="docker compose down -v"
alias dkcda="docker compose down -v --rmi all"
alias dkcim="docker compose images"
alias dkcps='docker compose ps'
alias dkcpsa='docker compose ps -a'
alias dkcr="docker compose run"
alias dkclogs="docker compose logs"
alias dkcls="docker compose ls"
alias dkcst="docker compose start"
alias dkcstp="docker compose stop"

# ----------------------------------------------------------------------------------------------------

alias mv='mv -v'
alias cp='cp -v'
alias rm='rm -v'

alias ssh='ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes'
alias sshu='ssh -o stricthostkeychecking=no -o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes'

alias t='tmux'
alias ta='tmux a'
alias tls='tmux ls'
alias tks='tmux kill-server'
# Tree colored output MAC.
alias tree='tree -C'

alias v="vim -u ~/.dotfiles/.basic.vimrc"
alias vz='vim `fzf -m`'

alias vi='vim -u `mktemp`'

alias gpg='gpg --no-symkey-cache'

alias gcf='f_git_staged_clang_format'
alias gcfa='f_git_staged_clang_format_all'

# +10, -31 -> not int
function is_unsigned_int () {
    case "$1" in
        (*[!0123456789]*) return 1 ;;
        ('')              return 1 ;;
        (*)               return 0 ;;
    esac
}

function gx() {
  src=$1
  shift
  g++ -o ${src}.out $@ $src && ./${src}.out
}


function g1() {
  #g++ --std=c++11 -o $1.out $1 && ./$1.out
  gx $@ --std=c++11
}

function g4() {
  #g++ --std=c++14 -o $1.out $1 && ./$1.out
  gx $@ --std=c++14
}

function g7() {
  #g++ --std=c++17 -o $1.out $1 && ./$1.out
  gx $@ --std=c++17
}

function g2b() {
  #g++ --std=c++23 -o $1.out $1 && ./$1.out
  gx $@ --std=c++2b
}

function g20() {
  #g++ --std=c++20 -o $1.out $1 && ./$1.out
  gx $@ --std=c++20
}

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

function parse_ssl_cert() {
  tmpfile=`mktemp`
  echo $tmpfile 1>&2
  echo ""
  #echo $1 | sed 's/\\n/\
#/g' | sed '$d' > $tmpfile
  # echo auto replaces '\n' with actual newlines
  echo $1 > $tmpfile

openssl x509 -in $tmpfile -text
}

function sshp {
  expect $HOME/workspace/misc/scripts/ssh_pass.exp $@
}

# DEPRECATED: use "$ (cmd) $!" to disown (portable?)
# Following errors seen when running just nohup zsh -ci '...':
#   - suspended (tty output) (stty -tostop didn't help)
#   - zsh: can't set tty pgrp: interrupt
#   - $HOME/.oh-my-zsh/oh-my-zsh.sh:24: bad tcgets: inappropriate ioctl for device
# USAGE: nhup "cmd/func/alias --arg1 val1 --arg2 'val2.1 val2.2'"
function nhup {
  # $* doesn't properly expand --arg 'val1 val2'
  # nohup bash -ci "zsh -ci '$*'" 2>&1 >~/.nohup.out &
  nohup bash -ci "zsh -ci '$@'" 2>&1 >~/.nohup.out &
}

function wait_for_remote_proc {
  remote=$1
  proc=$2
  # "tail -1" is suboptimal
  if is_unsigned_int $proc; then
    notif=`ssh $remote "ps -p $proc -o cmd | tail -1"`
    wait_for_cmd="ps -p $proc"
  else
    notif=`ssh $remote "pgrep -a $proc | tail -1"`
    # pidof
    wait_for_cmd="pgrep $proc"
  fi

  # TODO: what if pid was reused
  ssh -q $remote << EOD
    while $wait_for_cmd >/dev/null
    do
      sleep 2
    done
EOD
    osascript -e "display notification \"$notif\" with title \" cmd complete\" sound name \"\""
}

function echo_trlf_cp {
  echo -n $1 | tr '\n' ' ' | pbcopy
}

function decrypt_b64_rsa_oaep_sha256 {
  key_file=$1
  in_file=$2
  openssl pkeyutl -decrypt -inkey $key_file -in <(cat $in_file | base64 -D) -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
}

function decrypt_rsa_oaep_sha256 {
  key_file=$1
  in_file=$2
  openssl pkeyutl -decrypt -inkey $key_file -in $in_file -pkeyopt rsa_padding_mode:oaep -pkeyopt rsa_oaep_md:sha256
}

function f_dc {
  cd $(dirname $(find . -iname "compose.yaml"))
  docker compose $@
  cd - > /dev/null
}

function f_generate_ecdsa {
  KEY_FILE=$1
  openssl ecparam -genkey -name secp521r1 -out $KEY_FILE
  # extract the public key
  ssh-keygen -y -f $KEY_FILE > ${KEY_FILE}.pub
}

function f_rsa_pem_to_pkix_pub {
  # PUBLIC_KEY_PEM needs to be in PEM format:
    # ssh-keygen -f <pub-key>/<private-key> -e -m PEM
  PUBLIC_KEY_PEM=$1
  OUTPUT_FILE=$2
  openssl rsa -in $PUBLIC_KEY_PEM -pubin -RSAPublicKey_in -outform PEM -out $OUTPUT_FILE
}

function f_git_staged_clang_format {
  file=$1

  # Skip non cpp files
  if ! [[ $file =~ ".*\.cc" || $file =~ ".*\.h" ]];
  then
    echo "WARNING: Skipping non-cpp file: $file" 1>&2
    continue
  fi

  git diff -U1 --cached -- $file | while read line
  do
      if [[ $line =~ "^@@.*\+([0-9]+),([0-9]+).*@@" ]];
      then
          from=$(($match[1] + 1))
          to=$(($match[1] + $match[2] - 1))
          echo "INFO: Running clang-format on $file:$from:$to" 1>&2
          clang-format -i --style=file --fallback-style=google --lines=$from:$to $file
      fi
  done
}

function f_git_staged_clang_format_all {
  for changed_file in `git diff --name-only --cached`; do
    f_git_staged_clang_format $changed_file
  done
}
