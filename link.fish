#!/usr/bin/env fish

# Symlinks dotfiles into place. Safe to re-run: correct links are left alone,
# so after adding a table entry (or a new skill) just run it again.
#
# Each entry is "SOURCE TARGET". A SOURCE ending in /* links every
# subdirectory of it into the TARGET directory.

set links \
    "fish       $HOME/.config/fish" \
    "fuzzel     $HOME/.config/fuzzel" \
    "ghostty    $HOME/.config/ghostty" \
    "helix      $HOME/.config/helix" \
    "kak        $HOME/.config/kak" \
    "niri       $HOME/.config/niri" \
    "noctalia   $HOME/.config/noctalia" \
    "nvim       $HOME/.config/nvim" \
    "tmux       $HOME/.config/tmux" \
    "wezterm    $HOME/.config/wezterm" \
    "zellij     $HOME/.config/zellij" \
    "skills/*   $HOME/.claude/skills"

set dotfiles (realpath (status dirname))
set stamp (date +%Y%m%d%H%M%S)

# Expand the table into concrete "src target" pairs.
set pairs
for entry in $links
    set parts (string split -n ' ' -- $entry)
    set src $parts[1]
    set target $parts[2]

    if string match -q '*/\*' -- $src
        set dir (string replace -r '/\*$' '' -- $src)
        for sub in $dotfiles/$dir/*/
            set name (basename $sub)
            set -a pairs "$dotfiles/$dir/$name"\t"$target/$name"
        end
    else
        set -a pairs "$dotfiles/$src"\t"$target"
    end
end

# Work out what needs doing.
set plan
for pair in $pairs
    set src (string split \t -- $pair)[1]
    set target (string split \t -- $pair)[2]

    if test -L $target
        if test (readlink $target) = $src
            continue
        end
        set -a plan "relink"\t$src\t$target
    else if test -e $target
        set -a plan "backup"\t$src\t$target
    else
        set -a plan "link"\t$src\t$target
    end
end

if test (count $plan) -eq 0
    echo "Everything is already linked."
else
    echo "Planned changes:"
    for step in $plan
        set f (string split \t -- $step)
        switch $f[1]
            case link
                echo "  link     $f[3] -> $f[2]"
            case relink
                echo "  relink   $f[3] -> $f[2]  (was -> "(readlink $f[3])")"
            case backup
                echo "  backup   $f[3] -> $f[3].bak.$stamp, then link -> $f[2]"
        end
    end

    read -P "Apply these changes? [y/N] " answer
    if not string match -qi 'y*' -- $answer
        echo "Aborted, nothing changed."
        exit 1
    end

    for step in $plan
        set f (string split \t -- $step)
        mkdir -p (dirname $f[3])
        switch $f[1]
            case link
                ln -s $f[2] $f[3]
            case relink
                ln -sfn $f[2] $f[3]
            case backup
                mv $f[3] $f[3].bak.$stamp
                ln -s $f[2] $f[3]
        end
        echo "  done: $f[1] $f[3]"
    end
end
