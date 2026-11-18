#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
TMUX_PLUGINS=(
  tmux-plugins/tpm
  tmux-plugins/tmux-resurrect
  tmux-plugins/tmux-continuum
  christoomey/vim-tmux-navigator
)

link() {
  local source="$1" target="$2"
  mkdir -p "$(dirname "$target")"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.bak"
  fi
  ln -sfn "$source" "$target"
}

clone_tmux_plugin() {
  local repo="$1" dest="$HOME/.tmux/plugins/${1#*/}"
  [ -d "$dest/.git" ] || git clone -q --depth 1 "https://github.com/$repo" "$dest"
}

add_claude_hook() {
  local event="$1" command="$2" settings="$CLAUDE_DIR/settings.json" tmp
  [ -s "$settings" ] || echo '{}' >"$settings"
  tmp="$(mktemp "$settings.XXXXXX")"
  jq --arg e "$event" --arg c "$command" '
    if any(.hooks[$e][]?.hooks[]?; .command == $c) then .
    else .hooks[$e] = ((.hooks[$e] // []) + [{hooks: [{type: "command", command: $c}]}])
    end' "$settings" >"$tmp"
  mv "$tmp" "$settings"
}

link "$DOTFILES_DIR" "$HOME/.config/nvim"

link "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
link "$DOTFILES_DIR/tmux" "$HOME/.tmux/claude"
for plugin in "${TMUX_PLUGINS[@]}"; do
  clone_tmux_plugin "$plugin"
done

mkdir -p "$HOME/.claude/tmux/resurrect" "$CLAUDE_DIR/hooks"
hook_script="$CLAUDE_DIR/hooks/tmux-pane-session.sh"
ln -sfn "$DOTFILES_DIR/tmux/claude-pane-session.sh" "$hook_script"
add_claude_hook SessionStart "[ ! -x $hook_script ] || $hook_script add"
add_claude_hook SessionEnd "[ ! -x $hook_script ] || $hook_script remove"
