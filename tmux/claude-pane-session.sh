#!/usr/bin/env bash
set -uo pipefail
exec >/dev/null

STATE_DIR="$HOME/.claude/tmux"
PANE_MAP="$STATE_DIR/claude-panes.json"
LOCK_FILE="$STATE_DIR/claude-panes.lock"

action="${1:-}"
[ -n "${TMUX_PANE:-}" ] || exit 0
session_id="$(jq -r '.session_id // empty' 2>/dev/null)"
[ -n "$session_id" ] || exit 0

parent_of() {
  ps -o ppid= -p "$1" 2>/dev/null | tr -d ' '
}

find_claude_ancestor() {
  local pid="$PPID"
  while [ -n "$pid" ] && [ "$pid" -gt 1 ]; do
    if [ "$(ps -o comm= -p "$pid" 2>/dev/null)" = "claude" ]; then
      echo "$pid"
      return 0
    fi
    pid="$(parent_of "$pid")"
  done
  return 1
}

is_print_mode() {
  tr '\0' '\n' <"/proc/$1/cmdline" | grep -qxE -- '-p|--print'
}

is_interactive_claude_of_pane() {
  local claude_pid pane_pid
  claude_pid="$(find_claude_ancestor)" || return 1
  is_print_mode "$claude_pid" && return 1
  pane_pid="$(tmux display-message -p -t "$TMUX_PANE" '#{pane_pid}' 2>/dev/null)" || return 1
  [ "$claude_pid" = "$pane_pid" ] || [ "$(parent_of "$claude_pid")" = "$pane_pid" ]
}

update_pane_map() {
  mkdir -p "$STATE_DIR"
  exec 9>"$LOCK_FILE"
  flock 9
  [ -s "$PANE_MAP" ] || echo '{}' >"$PANE_MAP"
  local tmp
  tmp="$(mktemp "$STATE_DIR/.claude-panes.XXXXXX")"
  if jq "$@" "$PANE_MAP" >"$tmp"; then
    mv "$tmp" "$PANE_MAP"
  else
    rm -f "$tmp"
  fi
}

case "$action" in
add)
  is_interactive_claude_of_pane || exit 0
  update_pane_map --arg pane "$TMUX_PANE" --arg sid "$session_id" '.[$pane] = $sid'
  ;;
remove)
  # On /clear the old session's SessionEnd can run after the new SessionStart.
  update_pane_map --arg pane "$TMUX_PANE" --arg sid "$session_id" \
    'if .[$pane] == $sid then del(.[$pane]) else . end'
  ;;
esac
exit 0
