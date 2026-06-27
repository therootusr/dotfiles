function v() {
  vim -u "$MY_DOTFILES_DIR/vim/workman.basic.vimrc" "$@"
}

# Open vim with quickfix loaded from paste buffer (tmux or system clipboard).
function vpq() {
  if [[ -n "${TMUX:-}" ]]; then
    v -q <(tmux save-buffer -)
  else
    v -q <(pbpaste)
  fi
}

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

function ffz {
  local target_dir="${1:-$(pwd)}"
  find "$target_dir" | \
      fzf -m \
          --ansi \
          --prompt='copy-filepath> ' \
          --preview='wc {} && head {}' | \
      rcp
}

# Pipe ${GREP_CMD:-grep} results through fzf with preview, copy selection to clipboard.
# All args forwarded to the engine as-is. Output: file:line:match (vim-quickfix-compatible).
# Aliases: gg (recursive grep), ggz (git grep). See aliases.zsh.
function fzf_grep() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: fzf_grep [GREP_FLAGS...] PATTERN [PATH...]" >&2
    return 1
  fi

  local -a grep_cmd=(${=GREP_CMD:-grep})

  local -a defaults=(-In --color=always)

  local preview_cmd
  # fallback? preview_cmd='head -n $((({2} + 30))) {1} 2>/dev/null | tail -n 60'
  # If needed: ln -svf --backup=numbered `which batcat` ~/.local/bin/bat
  preview_cmd='bat --style=numbers --color=always --highlight-line {2} {1}'

  local result
  result=$("${grep_cmd[@]}" "${defaults[@]}" "$@" 2>/dev/null |
    fzf --multi --ansi \
        --delimiter=: \
        --preview="$preview_cmd" \
        --preview-window='down:50%:+{2}-10' \
        --prompt="${grep_cmd[*]}> " \
        --header='TAB=select  Enter=copy to clipboard')

  [[ -z "$result" ]] && return 0

  if [[ -n "${TMUX:-}" ]]; then
    printf '%s' "$result" | tmux load-buffer -w -
  else
    printf '%s' "$result" | rcp
  fi

  echo "$result"
}

# Amend staged changes into an existing commit.
# Usage: git_amend_to_commit [COMMIT]
#   If COMMIT is omitted, use fzf to pick from git log (if available).
# gac -> git_amend_to_commit
function gac() {
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "ERROR: not a git repo" >&2
    return 1
  fi

  # Can check if rebase/merge/bisect etc. is running like git's own
  # git-prompt.sh does it (checks files under .git dir) and fail fast.
  # Currently, rely on end-user to know when to trigger this.

  if git diff --cached --quiet; then
    echo "ERROR: no staged changes" >&2
    return 1
  fi

  local target="${1:-}"
  if [[ -z "$target" ]]; then
    if command -v fzf >/dev/null 2>&1; then
      target=$(git log --oneline --decorate --no-color -n 30 | fzf --ansi --prompt="commit> " --delimiter=' ' --preview='git show --format=fuller --numstat --shortstat -p --color=always {1}' | awk '{print $1}')
    else
      git log --oneline --decorate -n 30
      echo -n "Commit: "
      read -r target
    fi
  fi

  if [[ -z "$target" ]]; then
    echo "ERROR: no commit selected" >&2
    return 1
  fi

  if ! git rev-parse --verify "$target^{commit}" >/dev/null 2>&1; then
    echo "ERROR: invalid commit: $target" >&2
    return 1
  fi

  local target_sha
  target_sha=$(git rev-parse "$target")

  if ! git merge-base --is-ancestor "$target_sha" HEAD >/dev/null 2>&1; then
    echo "ERROR: commit is not an ancestor of HEAD" >&2
    return 1
  fi

  # Disallow if target is a merge commit (needed even if we use --rebase-merges in future)
  if [[ $(git rev-list --parents -n 1 "$target_sha" | wc -w) -gt 2 ]]; then
    echo "ERROR: target commit is a merge commit" >&2
    return 1
  fi

  # Fail fast and don't flatten any merge commits.
  # Future: consider --rebase-merges flag if this is needed.
  if [[ $(git rev-list --merges "${target_sha}..HEAD" | wc -l) -gt 0 ]]; then
    echo "ERROR: merge commits present in the rebase history" >&2
    return 1
  fi

  if [[ "$target_sha" == "$(git rev-parse HEAD)" ]]; then
    git commit --amend --no-edit
    return $?
  fi

  git commit --fixup "$target_sha" || return $?

  # If target's root, then run with '--root'
  if git rev-parse --verify "${target_sha}^" >/dev/null 2>&1; then
    GIT_SEQUENCE_EDITOR="${GIT_SEQUENCE_EDITOR:-:}" \
      git rebase -i --autosquash --autostash "${target_sha}^"
  else
    GIT_SEQUENCE_EDITOR="${GIT_SEQUENCE_EDITOR:-:}" \
      git rebase -i --autosquash --autostash --root
  fi
}

function glz() {
  git log --oneline --decorate --no-color $@ | \
      fzf --ansi \
          --prompt="commit> " \
          --delimiter=' ' \
          --preview='git show --format=fuller --numstat --shortstat -p --color=always {1}' | \
      awk '{print $1}'
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
function mac_watch() {
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

# https://jvns.ca/til/vim-osc52/
# rcp -> remote_cp : copy stdin to the clipboard via OSC 52 (SSH-friendly).
# Strips trailing newline(s) so nothing stray lands in the clipboard.
function rcp() {
  local content
  content="$(cat)"               # command substitution strips trailing newlines
  [[ -z "$content" ]] && return 0  # don't clobber the clipboard on empty input
  printf '\033]52;c;%s\007' "$(printf '%s' "$content" | base64 | tr -d '\n')"
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
  local -r remote=$1
  local -r proc=$2
  # "tail -1" is suboptimal
  if is_unsigned_int $proc; then
    local -r notif=`ssh $remote "ps -p $proc -o cmd | tail -1"`
    local -r wait_for_cmd="ps -p $proc"
  else
    local -r notif=`ssh $remote "ps -o pid,cmd ax | grep $proc | grep -v \"grep $proc\" | tail -1"`
    local -r pid=`echo $notif | grep -o "[^ ].*" |  cut -d' ' -f1`
    # pidof
    local -r wait_for_cmd="ps -p $pid"
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

function f_pc {
  cd $(dirname $(find . -iname "compose.yaml"))
  podman compose $@
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

# ws: whitespace
function ws_trim {
  sed -i '' -e 's/^[[:space:]]*$//g' -e 's/[[:space:]]*$//g' $1
}

# ws: whitespace
function gws_trim {
  sed -i '' -e 's/^[[:space:]]*$//g' -e 's/[[:space:]]*$//g' $(git diff --name-only --cached)
}

# prints max mem used in kb
function xtime {
  /usr/bin/time -f '%Uu %Ss %er %MkB %C' "$@"
}

function test_block_dev_perf {
  local block_dev=$1
  # sync # exec `sync`?
  hdparm -t $block_dev
}

# what about checking fs metadata perf?
function test_disk_perf {
  local fio_filepath=$1
  fio --name=randrw4k --rw=randrw --bs=4k --iodepth=32 --size=2G --runtime=30 --time_based --ioengine=io_uring --direct=1 --filename=$fio_filepath --group_reporting
}

function tfch {
  local target_dir=$1
  shift
  terraform -chdir=$target_dir $@
}

# kdeb my-pod-0                         # Uses current namespace, /bin/bash
# kdeb some-pod my-namespace            # Specify namespace
# kdeb custom-pod my-namespace /bin/sh  # Custom shell
function kdeb() {
  local pod=${1:?Usage: kdeb <pod-name> [namespace] [shell]}
  local ns=${2:-$(kubectl config view --minify -o jsonpath='{..namespace}' 2>/dev/null || echo default)}
  local shell=${3:-/bin/bash}
  local image=$(kubectl get pod "$pod" -n "$ns" -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
  [ -z "$image" ] && { echo "Error: Could not get image for pod $pod in namespace $ns" >&2; return 1 }
  kubectl run "debug-${pod}" \
    --image="$image" --rm -it --restart=Never -n "$ns" \
    --overrides="{\"spec\":{\"containers\":[{\"name\":\"debug-${pod}\",\"image\":\"${image}\",\"command\":[\"${shell}\"],\"stdin\":true,\"tty\":true}]}}"
}

# May wanna "Reload Window" afterwards
function import_cursor_rules() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "FATAL: not a git repo"
    return 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  local kMyCursorRulesDir="${HOME}/workspace/personal/app-configs/cursor/rules"
  readonly kMyCursorRulesDir

  if [  -e ".cursor/rules" ]; then
    mkdir -p ".cursor/rules/external"
    # Cursor refuses to recognize symlinks within .cursor/rules/
    cp -vr "${kMyCursorRulesDir}"/. ".cursor/rules/external/"
  else
    mkdir -pv .cursor
    ln -vs "${kMyCursorRulesDir}" .cursor/
  fi
}

function import_obsidian_carbon_snippet() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "FATAL: not a git repo"
    return 1
  fi
  cd "$(git rev-parse --show-toplevel)"

  local kObsidianCarbonCssFile="${HOME}/workspace/personal/app-configs/obsidian/snippets/obsidian-carbon.css"
  readonly kMyCursorRulesDir

  local obsidianSnippetsDir=".obsidian/snippets"
  local relativeTargetPath=".obsidian/snippets/obsidian-carbon.css"
  readonly obsidianSnippetsDir relativeTargetPath

  mkdir -pv $obsidianSnippetsDir
  if [  -e "$relativeTargetPath" ]; then
    # ln --backup=<> needn't work on mac
    mv -v "$relativeTargetPath" "$relativeTargetPath.$(date | tr ' ' '-d' | tr -s '-')"
  fi

  ln -fv "$kObsidianCarbonCssFile" "$relativeTargetPath"
}

# Debug a Kubernetes node: run an ephemeral privileged shell on the node.
# Usage: kdebn [NODE_NAME] [IMAGE]
#   NODE_NAME  optional; if omitted, chosen interactively via fzf or first node
#   IMAGE      optional; default busybox (use ubuntu, alpine, etc. for more tools)
function kdebn() {
  local node="${1:-}"
  local image="${2:-busybox}"
  if [[ -z "$node" ]]; then
    echo "kdebn: no node selected" >&2
    echo "Usage: kdebn [NODE_NAME] [IMAGE]" >&2
    return 1
  fi
  echo "Debugging node: $node (image: $image). Exit shell when done." >&2
  kubectl debug "node/$node" -it --image="$image" -- chroot /host /bin/sh
  # NO 'kubectl debug --rm': enhance to auto-delete the pod? Needs to perfect, can't delete any other pod
}

# Symmetric diff of file contents (by SHA256). Ignores paths/filenames; prints paths per tree.
function diff_tree_content() {
  local d1 d2 t1f t2f o1 o2
  d1="$(realpath $1)"
  d2="$(realpath $2)"
  t1f=$(mktemp) t2f=$(mktemp) o1=$(mktemp) o2=$(mktemp)
  (cd "$d1" && find . -type d -name .git -prune -o -type f -exec sha256sum {} + 2>/dev/null) | sort -k1,1 > "$t1f"
  (cd "$d2" && find . -type d -name .git -prune -o -type f -exec sha256sum {} + 2>/dev/null) | sort -k1,1 > "$t2f"
  comm -23 <(cut -d' ' -f1 "$t1f" | sort -u) <(cut -d' ' -f1 "$t2f" | sort -u) > "$o1"
  comm -13 <(cut -d' ' -f1 "$t1f" | sort -u) <(cut -d' ' -f1 "$t2f" | sort -u) > "$o2"
  echo "Only in $d1:"
  awk 'NR==FNR{a[$1];next} $1 in a {sub(/^[^ ]+  \*?/,""); print "  " $0}' "$o1" "$t1f"
  echo "Only in $d2:"
  awk 'NR==FNR{a[$1];next} $1 in a {sub(/^[^ ]+  \*?/,""); print "  " $0}' "$o2" "$t2f"
  /usr/bin/rm -f "$t1f" "$t2f" "$o1" "$o2"
}

# Symmetric diff by (basename, content). Same name + same content = match.
function diff_tree_name() {
  local d1 d2 t1 t2
  d1="$(realpath $1)" d2="$(realpath $2)"
  t1=$(mktemp) t2=$(mktemp)
  (cd "$d1" && find . -type d -name .git -prune -o -type f -exec sh -c 'for f; do printf "%s\t%s\n" "$(basename "$f")" "$(sha256sum < "$f" | awk "{print \$1}")"; done' _ {} + 2>/dev/null) | sort -u > "$t1"
  (cd "$d2" && find . -type d -name .git -prune -o -type f -exec sh -c 'for f; do printf "%s\t%s\n" "$(basename "$f")" "$(sha256sum < "$f" | awk "{print \$1}")"; done' _ {} + 2>/dev/null) | sort -u > "$t2"
  echo "Only in $d1 (name+sha256sum):"
  comm -23 "$t1" "$t2"
  echo "Only in $d2 (name+sha256sum):"
  comm -13 "$t1" "$t2"
  /usr/bin/rm -f "$t1" "$t2"
}

# Copy a range of commits from one repo to another and reset author (keep dates).
# Usage: git_copy_commits_to_repo <source-dir> <target-dir> <sha|sha1..sha2>
function git_cp_commits() {
  local src="$1" tgt="$2" rev="$3" range old_head
  [[ -z "$src" || -z "$tgt" || -z "$rev" ]] && { echo "Usage: git_copy_commits_to_repo <source-dir> <target-dir> <sha|sha1..sha2>" >&2; return 1; }
  [[ ! -d "$src/.git" || ! -d "$tgt/.git" ]] && { echo "Source and target must be git repos." >&2; return 1; }
  if [[ "$rev" == *..* ]]; then range="$rev"; else range="${rev}^..${rev}"; fi
  old_head=$(git -C "$tgt" rev-parse HEAD 2>/dev/null) || true
  git -C "$src" format-patch "$range" --stdout | git -C "$tgt" am
  (cd "$tgt" && git rebase -r "${old_head:---root}" --exec 'author_date="$(git log -1 HEAD --pretty=format:"%aI")" && git commit --amend --no-edit --reset-author --date="$author_date"')
}

# alias git_reset_author='git rebase -r --root --exec '\''author_date="$(git log -1 HEAD --pretty=format:"%aI")" &&  git commit --amend --no-edit --reset-author --date="$author_date"'\'''
function git_reset_author() {
  local base="${1:?usage: git_reset_author <base-ref|--root>}"
  git rebase -r "$base" --exec 'author_date="$(git log -1 HEAD --pretty=format:"%aI")" && git commit --amend --no-edit --reset-author --date="$author_date"'
}

# Save the image on the macOS clipboard to a PNG file.
# Usage: pimg [path.png]   (defaults to a timestamped name in $PWD)
#        pimg && imgcat "$(pimg)"   # capture the printed path
func pimg() {
  local file="${1:-screenshot-$(date +%Y%m%d-%H%M%S).png}"

  # Resolve to an absolute path so osascript writes where you expect.
  [[ "$file" = /* ]] || file="$PWD/$file"

  # Escape \ and " for the AppleScript string literal.
  local esc=${file//\\/\\\\}
  esc=${esc//\"/\\\"}

  if osascript \
      -e 'set pngData to (the clipboard as «class PNGf»)' \
      -e 'set f to (open for access (POSIX file "'"$esc"'") with write permission)' \
      -e 'try' \
      -e '    set eof f to 0' \
      -e '    write pngData to f' \
      -e '    close access f' \
      -e 'on error errMsg' \
      -e '    close access f' \
      -e '    error errMsg' \
      -e 'end try' 2>/dev/null
  then
    echo "$file"
  else
    echo "pimg: no image on the clipboard" >&2
    return 1
  fi
}

# tfan (tmux fan) CMD... — open a tiled pane per whitespace-separated token in
# the top-most tmux buffer and run CMD in it. The token replaces {} anywhere in
# CMD (xargs-style); with no {} it's appended to the end. Panes are real shells
# (CMD is sent via send-keys), so they stay open on exit/error. Run inside tmux.
#   buffer: "web1 web2"
#   tfan "ssh {}"          ->  per pane: ssh web1        / ssh web2
#   tfan "ping {} -c1"     ->  per pane: ping web1 -c1   / ping web2 -c1
#   tfan "ssh "            ->  per pane: ssh web1        (no {} -> token appended)
tfan() {
  [ -n "$TMUX" ] || { echo "tfan: must be run inside a tmux session" >&2; return 1; }
  [ "$#" -gt 0 ] || { echo "tfan: usage: tfan CMD... ({} = buffer token, else appended)" >&2; return 1; }

  local cmd="$*" buf line first=1 tok
  buf=$(tmux show-buffer 2>/dev/null)

  [ -n "$ZSH_VERSION" ] && setopt local_options sh_word_split   # zsh: word-split $buf like bash

  for tok in $buf; do
    case "$cmd" in
      *'{}'*) line=${cmd//\{\}/$tok} ;;   # {} -> token, anywhere in CMD
      *)      line="$cmd$tok" ;;          # no {} -> append to the end
    esac
    if [ "$first" = 1 ]; then
      tmux new-window -c "#{pane_current_path}"; first=0
    else
      tmux split-window -v -c "#{pane_current_path}"
      tmux select-layout tiled
    fi
    tmux send-keys "$line" Enter
  done
  [ "$first" = 0 ] || { echo "tfan: no tokens in top tmux buffer" >&2; return 1; }
  tmux select-layout tiled
}

# cshred (compat shred) FILE... — overwrite each file with random bytes (via
# openssl), flush, then unlink it. A portable stand-in for shred(1) on boxes
# that don't ship it. Single pass; best-effort only (no guarantee on copy-on-
# write filesystems, SSDs with wear-leveling, or anything that snapshots).
# Writes raw random bytes, not ascii: max entropy, and the bytes are discarded
# anyway, so there's no reason to restrict them to a printable subset.
#   cshred secret.key             # overwrite + remove one file
#   cshred *.pem creds.json       # several at once
cshred() {
  [ "$#" -gt 0 ] || { echo "cshred: usage: cshred FILE..." >&2; return 1; }
  command -v openssl >/dev/null 2>&1 || { echo "cshred: openssl not found" >&2; return 1; }

  local f size rc=0
  for f in "$@"; do
    if [ -L "$f" ] || [ ! -f "$f" ]; then
      echo "cshred: $f: not a regular file" >&2; rc=1; continue   # skip symlinks, dirs, devices, missing
    fi
    if [ ! -w "$f" ]; then
      echo "cshred: $f: not writable" >&2; rc=1; continue
    fi
    # File size, portably: GNU stat (-c%s) then BSD/macOS stat (-f%z).
    size=$(stat -c%s "$f" 2>/dev/null || stat -f%z "$f" 2>/dev/null)
    if [ -z "$size" ]; then
      echo "cshred: $f: cannot determine size; skipping" >&2; rc=1; continue
    elif [ "$size" -gt 0 ]; then
      if ! openssl rand "$size" > "$f"; then   # leave the (now-clobbered) file so the failure is visible
        echo "cshred: $f: overwrite failed" >&2; rc=1; continue
      fi
      sync
    fi
    rm -f "$f" || rc=1
  done
  return "$rc"
}
