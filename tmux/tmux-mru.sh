#!/usr/bin/env bash
# tmux-mru.sh - Unified MRU navigation for tmux windows and panes.
#
# Maintains a per-session stack of (window_id, pane_id) pairs ordered by
# most-recently-used. Two prefix-less keys walk the stack; a pane-focus-in
# hook keeps it up to date.
#
# Usage:  tmux-mru.sh {hook|back|forward}
#   hook    - called by pane-focus-in hook (promotes current pane to MRU front)
#   back    - navigate to older MRU entry
#   forward - navigate to newer MRU entry
#
# stdout is captured by tmux run-shell and displayed in the message area.

# ── Configuration ────────────────────────────────────────────────────────────
MRU_WALK_TIMEOUT_SECS=4
MRU_STATE_DIR="$HOME/workspace/tmp/tmux/session-state"
# ── Configuration ────────────────────────────────────────────────────────────

die() { printf '[tmux-mru] ERROR: %s\n' "$1"; exit 1; }
warn() { printf '[tmux-mru]: %s\n' "$1"; }

# ── tmux environment helpers ─────────────────────────────────────────────────
# Session-scoped env vars (current session in run-shell context).
# Returns 1 if the variable is unset or explicitly removed ("-VAR" form).
tmux_env_get() {
    local raw
    raw="$(tmux show-environment "$1" 2>/dev/null)" || return 1
    case "$raw" in -*) return 1 ;; esac
    printf '%s' "${raw#*=}"
}

tmux_env_set() {
    tmux set-environment "$1" "$2" \
        || die "set-env failed: $1=$2"
}

tmux_env_unset() {
    tmux set-environment -u "$1" 2>/dev/null || true
}

clear_walk_state() {
    tmux_env_unset @mru_walk_until
    tmux_env_unset @mru_cursor
    # set-option (not env var) so status-left can read it via #{?@mru_walking,...}
    tmux set-option -u @mru_walking 2>/dev/null || true
    tmux refresh-client -S
}
# ── tmux environment helpers ─────────────────────────────────────────────────

# ── MRU file path ────────────────────────────────────────────────────────────
# One file per session: <session_name>.<epoch>.mru
# The epoch is captured once per session lifetime and stored in @mru_epoch.
get_mru_file() {
    local session_name epoch safe_name
    session_name="$(tmux display-message -p '#{session_name}')" \
        || die "display-message failed (not in tmux?)"
    [ -n "$session_name" ] || die "empty session name"

    if ! epoch="$(tmux_env_get @mru_epoch)"; then
        epoch="$(date +%s)"
        tmux_env_set @mru_epoch "$epoch"
    fi

    mkdir -p "$MRU_STATE_DIR" \
        || die "mkdir failed: $MRU_STATE_DIR"

    safe_name="$(printf '%s' "$session_name" | tr '/: ' '___')"
    printf '%s' "$MRU_STATE_DIR/${safe_name}.${epoch}.mru"
}
# ── MRU file path ────────────────────────────────────────────────────────────

# ── Stack operations ─────────────────────────────────────────────────────────
promote() { # write new head + filtered old entries to tmp, then atomic mv
    local wid="$1" pid="$2" mru_file="$3"
    local entry="$wid $pid"
    local tmp="${mru_file}.$$"
    {
        printf '%s\n' "$entry"
        if [ -f "$mru_file" ]; then
            grep -xvF "$entry" "$mru_file" || true
        fi
    } > "$tmp" || die "write failed: $tmp"
    mv -f "$tmp" "$mru_file" || die "mv failed: $tmp -> $mru_file"
}

remove_entry() {
    local entry="$1" mru_file="$2"
    local tmp="${mru_file}.$$"
    [ -f "$mru_file" ] || return 0
    grep -xvF "$entry" "$mru_file" > "$tmp" || true
    mv -f "$tmp" "$mru_file" || die "mv failed: $tmp -> $mru_file"

}
# ── Stack operations ─────────────────────────────────────────────────────────

# ── Hook handler ─────────────────────────────────────────────────────────────
cmd_hook() {
    local wid pid mru_file walk_until now
    wid="$(tmux display-message -p '#{window_id}')" \
        || die "display-message failed for window_id"
    pid="$(tmux display-message -p '#{pane_id}')" \
        || die "display-message failed for pane_id"
    [ -n "$wid" ] || die "empty window_id"
    [ -n "$pid" ] || die "empty pane_id"

    mru_file="$(get_mru_file)"

    # Suppress promote during walk so rapid MRU cycling doesn't reorder the stack
    if walk_until="$(tmux_env_get @mru_walk_until)"; then
        now="$(date +%s)"
        if [ "$now" -lt "$walk_until" ]; then
            return 0
        fi
        clear_walk_state
    fi

    promote "$wid" "$pid" "$mru_file"
}
# ── Hook handler ─────────────────────────────────────────────────────────────

# ── Navigation ───────────────────────────────────────────────────────────────
cmd_navigate() {
    local direction="$1"
    local mru_file cursor total line wid pid now walk_until deadline

    mru_file="$(get_mru_file)"

    if [ ! -f "$mru_file" ]; then
        warn "no history yet (switch panes to build)"
        return 0
    fi

    total="$(wc -l < "$mru_file")" \
        || die "read failed: $mru_file"
    total="${total// /}"
    if [ "$total" -le 1 ]; then
        warn "only $total entry (need >=2 to navigate)"
        return 0
    fi

    now="$(date +%s)"
    if walk_until="$(tmux_env_get @mru_walk_until)" && [ "$now" -lt "$walk_until" ]; then
        cursor="$(tmux_env_get @mru_cursor)" || cursor=0
    else
        # Fresh walk: ensure pos 0 = current pane. Walks suppress stack updates,
        # so after expiry the stack top may not reflect where the user actually is.
        clear_walk_state
        wid="$(tmux display-message -p '#{window_id}')" || die "display-message failed"
        pid="$(tmux display-message -p '#{pane_id}')" || die "display-message failed"
        promote "$wid" "$pid" "$mru_file"
        total="$(wc -l < "$mru_file")"; total="${total// /}"
        cursor=0
    fi

    case "$direction" in
        back)    cursor=$((cursor + 1)) ;;
        forward) cursor=$((cursor - 1)) ;;
    esac

    if [ "$cursor" -ge "$total" ]; then
        cursor=0
    elif [ "$cursor" -lt 0 ]; then
        cursor=$((total - 1))
    fi

    deadline=$((now + MRU_WALK_TIMEOUT_SECS))
    tmux_env_set @mru_walk_until "$deadline"

    local pruned=0
    while [ "$total" -gt 1 ]; do
        line="$(sed -n "$((cursor + 1))p" "$mru_file")"
        [ -n "$line" ] || die "empty line at pos $((cursor+1))/$total in $mru_file"
        wid="${line%% *}" pid="${line##* }"

        if tmux select-window -t "$wid" 2>/dev/null \
                && tmux select-pane -t "$pid" 2>/dev/null; then
            break
        fi

        remove_entry "$line" "$mru_file"
        pruned=$((pruned + 1))
        total=$((total - 1))
        [ "$cursor" -ge "$total" ] && cursor=0
    done

    if [ "$total" -le 1 ]; then
        clear_walk_state
        [ "$pruned" -gt 0 ] && tmux display-message -d 1500 "pruned $pruned stale entries"
        return 0
    fi

    tmux_env_set @mru_cursor "$cursor"

    local arrow
    case "$direction" in back) arrow="◀" ;; forward) arrow="▶" ;; esac
    local indicator="MRU $arrow $((cursor + 1))/$total"
    [ "$pruned" -gt 0 ] && indicator="$indicator (pruned $pruned)"
    tmux set-option @mru_walking "$indicator"
    tmux refresh-client -S

    # deadline as generation ID: stale timers no-op when a newer keypress bumps it
    tmux run-shell -b "sleep $MRU_WALK_TIMEOUT_SECS; \
        v=\$(tmux show-environment @mru_walk_until 2>/dev/null); v=\${v#*=}; \
        [ \"\$v\" = \"$deadline\" ] \
        && tmux set-option -u @mru_walking 2>/dev/null \
        && tmux refresh-client -S; true"
}
# ── Navigation ───────────────────────────────────────────────────────────────

case "${1:-}" in
    hook)    cmd_hook ;;
    back)    cmd_navigate back ;;
    forward) cmd_navigate forward ;;
    *)       die "unknown cmd '${1:-}' (usage: hook|back|forward)" ;;
esac
