#!/usr/bin/env fish
# Link bastille templates (FreeBSD, needs root)
set dotfiles (realpath (status dirname))
doas mkdir -p /usr/local/bastille/templates
doas ln -sfn $dotfiles/bastille /usr/local/bastille/templates/rob
