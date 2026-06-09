#!/usr/bin/env bash
# CHANGEME: this is skeleton file from neovim

set -euo pipefail

session=$1

dir=$(dirname "$(realpath "${BASH_SOURCE[0]}")")

tmux new-window -t "$session" -c "$dir"
tmux previous-window -t "$session"
tmux send-keys -t "$session" "nvim flake.nix" Enter
