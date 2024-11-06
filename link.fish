#!/usr/bin/env fish

mkdir -p $HOME/.config
ln -s "$(pwd)/kak" "$HOME/.config/kak"
ln -s "$(pwd)/tmux" "$HOME/.config/tmux"
ln -s "$(pwd)/helix" "$HOME/.config/helix"
