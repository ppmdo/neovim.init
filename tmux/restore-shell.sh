#!/bin/sh
# zsh draws its prompt at row 0 if the pane resizes during restore, which pushes the restored contents into scrollback.
sleep 3
exec "${SHELL:-zsh}" -l
