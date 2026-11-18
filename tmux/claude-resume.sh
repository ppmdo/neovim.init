#!/usr/bin/env bash
set -euo pipefail

ADDRESS_MAP="$HOME/.claude/tmux/claude-panes-by-address.json"

address="$(tmux display-message -p -t "$TMUX_PANE" '#{session_name}:#{window_index}.#{pane_index}')"
session_id="$(jq -r --arg a "$address" '.[$a] // empty' "$ADDRESS_MAP" 2>/dev/null || true)"

if [ -z "$session_id" ]; then
  echo "tmux-claude-resume: no saved Claude session for pane $address. Run 'claude --resume' to pick one."
  exit 0
fi

exec claude --resume "$session_id" --permission-mode auto
