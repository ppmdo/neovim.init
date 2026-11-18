#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="$HOME/.claude/tmux"
PANE_MAP="$STATE_DIR/claude-panes.json"
ADDRESS_MAP="$STATE_DIR/claude-panes-by-address.json"
LOCK_FILE="$STATE_DIR/claude-panes.lock"

mkdir -p "$STATE_DIR"
exec 9>"$LOCK_FILE"
flock 9
[ -s "$PANE_MAP" ] || echo '{}' >"$PANE_MAP"

pane_addresses="$(
  tmux list-panes -a -F '#{pane_id}	#{session_name}:#{window_index}.#{pane_index}' |
    jq -R -s 'split("\n") | map(select(length > 0) | split("\t") | {(.[0]): .[1]}) | add // {}'
)"

write_json() {
  local target="$1" tmp
  shift
  tmp="$(mktemp "$STATE_DIR/.tmp.XXXXXX")"
  jq -n "$@" >"$tmp"
  mv "$tmp" "$target"
}

write_json "$ADDRESS_MAP" --argjson addr "$pane_addresses" --slurpfile map "$PANE_MAP" \
  '$addr | to_entries | map(select($map[0][.key]) | {(.value): $map[0][.key]}) | add // {}'

write_json "$PANE_MAP" --argjson addr "$pane_addresses" --slurpfile map "$PANE_MAP" \
  '$map[0] | with_entries(select($addr[.key]))'
