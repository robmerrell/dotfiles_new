function zj --description 'Pick a zellij session with fzf and attach'
    set -l session (zellij list-sessions --no-formatting --short | fzf --height 40% --reverse)
    test -n "$session"; and zellij attach $session
end
