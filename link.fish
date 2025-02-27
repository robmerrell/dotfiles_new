#!/usr/bin/env fish

mkdir -p $HOME/.config
ln -s "$(pwd)/fish" "$HOME/.config/fish"
ln -s "$(pwd)/tmux" "$HOME/.config/tmux"
ln -s "$(pwd)/kak" "$HOME/.config/kak"
ln -s "$(pwd)/helix" "$HOME/.config/helix"
ln -s "$(pwd)/nvim" "$HOME/.config/nvim"
