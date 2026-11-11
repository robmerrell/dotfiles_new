#!/usr/bin/env fish

# ln -s (pwd)/NAME ~/.config/NAME

set dotfiles (pwd)
mkdir -p $HOME/.config

for dir in fish fuzzel ghostty helix kak niri noctalia nvim tmux wezterm zellij
    set target $HOME/.config/$dir

    if test -e $target; and not test -L $target
        mv $target $target.bak
    end

    ln -s $dotfiles/$dir $target
end
