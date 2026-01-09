#!/usr/bin/env bash
# CHANGEME: this is skeleton file from neovim

set -euo pipefail

session=$1

tmux new-window -t "$session" -c "#{pane_current_path}"
tmux previous-window -t "$session"
tmux send-keys -t "$session" "vim flake.nix" Enter
