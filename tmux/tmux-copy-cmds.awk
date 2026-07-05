#!/usr/bin/awk -f
# tmux-copy-cmds.awk — parse tmux scrollback into command blocks.
#
# Usage: awk -f tmux-copy-cmds.awk -v include_shell_prompt=0|1 -v dir=DIR \
#            PROMPTS SCROLLBACK
#
# Writes each block (prompt-stripped command line + its output) to dir/blk.<idx>
# and a preview twin to dir/blk-with-full-prompt.<idx> — the block as it
# appeared on screen: the prompt's num-prompt-lines-above lines (p10k's
# cwd/branch/time info line), the raw marker line, then the output. Picking
# context only, independent of the include knob; the copy always comes from
# blk.<idx>. Prints one manifest line per block:
#   <idx>\t<display_command>\t<block_file>\t<preview_file>
#   include_shell_prompt  (-v) 1 = keep the prompt marker in copied text
#                         (not "include": gawk reserves its directive words
#                         include/load/namespace as variable names, and the
#                         engine must run under both mawk and gawk)
#   dir                   (-v) directory for block files
#
# PROMPTS — the FIRST input file (see tmux-copy-cmds.shell-prompts.example) —
# is the shell-prompt-type table: <marker-ERE><TAB><num-prompt-lines-above>
# rows. MARK[t] is the ERE for a command-start line;
# NUM_PROMPT_LINES_ABOVE[t] is how many prompt lines that prompt paints
# ABOVE its marker line (p10k's info line; the marker line itself is not
# counted), trimmed from the tail of the previous block. That count being a
# property of the next marker's type — not a global — is what reassembles a
# mixed local+ssh scrollback cleanly: a block ending at a bash prompt keeps
# its last output line, a block ending at a p10k prompt sheds the info line.
# Rows are tried in order; the first match wins.
#
# The table rides in as an input file, not -v (POSIX awk escape-processes -v
# values, mangling regex backslashes), guarded by FILENAME == ARGV[1] (the
# NR==FNR idiom breaks on an empty first file). Fail-fast: any structural
# problem — wrong field count, empty ERE, non-numeric
# num-prompt-lines-above, CRLF/BOM, zero rows — is one stderr line + exit 2
# before any scrollback work; malformed rows are never skipped. A bad ERE is
# a mawk fatal (there is no try/catch): the compile probe below forces it at
# the config line, and the sh wrapper turns any nonzero exit into a
# display-message.
#
# The strip is the marker match itself plus following whitespace, so it can
# never eat command text. A marker with nothing typed after it is a
# live/empty prompt, never a block (but it still bounds the previous one).

function die_cfg(why) {
  printf "prompts config %s line %d: %s\n", FILENAME, FNR, why > "/dev/stderr"
  died = 1
  exit 2
}

FILENAME == ARGV[1] {                              # shell-prompt-type table
  if (FNR == 1 && substr($0, 1, 3) == "\357\273\277")
    die_cfg("UTF-8 BOM at start of file")
  if ($0 ~ /\r$/) die_cfg("CRLF line ending (file must be LF-only)")
  if ($0 !~ /[^[:space:]]/) next                   # blank
  if (substr($0, 1, 1) == "#") next                # comment
  nf = split($0, f, "\t")
  if (nf != 2)
    die_cfg("need <marker-ERE><TAB><num-prompt-lines-above>, got " nf " tab-separated field(s)")
  if (f[1] == "") die_cfg("empty marker ERE")
  if (f[2] !~ /^[0-9]+$/)
    die_cfg("num-prompt-lines-above must be a plain number, got \"" f[2] "\"")
  NT++; MARK[NT] = f[1]; NUM_PROMPT_LINES_ABOVE[NT] = f[2] + 0   # mawk: force numeric
  junk = ("" ~ f[1])                               # compile the ERE now: a bad one
  next                                             # dies at this line, not mid-scan
}

{ L[++nl] = $0 }                    # scrollback (own counter: NR spans both files)

END {
  if (died) exit 2                  # exit inside a rule still lands in END
  if (NT < 1) {
    printf "prompts config %s: no prompt rows (only comments/blank lines?)\n", ARGV[1] > "/dev/stderr"
    exit 2
  }
  inc = include_shell_prompt + 0; out = 0          # mawk: force numeric
  for (i = 1; i <= nl; i++)
    for (t = 1; t <= NT; t++)
      if (L[i] ~ MARK[t]) { m[++mc] = i; mt[mc] = t; break }

  for (j = 1; j <= mc; j++) {
    s = m[j]
    match(L[s], MARK[mt[j]])
    rest = substr(L[s], RSTART + RLENGTH)          # RSTART tolerates unanchored markers
    if (rest !~ /[^[:space:]]/) continue           # live/empty prompt
    if (inc) cmd = L[s]
    else { sub(/^[[:space:]]+/, "", rest); cmd = rest }

    e = (j < mc) ? m[j + 1] - NUM_PROMPT_LINES_ABOVE[mt[j + 1]] - 1 : nl
    file = dir "/blk." out
    blk_with_full_prompt = dir "/blk-with-full-prompt." out
    prompt_start = s - NUM_PROMPT_LINES_ABOVE[mt[j]]     # own prompt's first painted line
    min_prompt_start = (j > 1) ? m[j - 1] + 1 : 1        # never reach back past the previous marker
    if (prompt_start < min_prompt_start)
      prompt_start = min_prompt_start
    for (k = prompt_start; k <= s; k++)                  # the prompt as painted on screen,
      print L[k] > blk_with_full_prompt                  # marker line included: preview-only
    print cmd > file
    for (k = s + 1; k <= e; k++) {
      print L[k] > file
      print L[k] > blk_with_full_prompt
    }
    close(file)
    close(blk_with_full_prompt)
    gsub(/\t/, " ", cmd)                           # keep the manifest tab-delimited
    print out "\t" cmd "\t" file "\t" blk_with_full_prompt
    out++
  }
}
