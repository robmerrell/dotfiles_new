# plug "andreyorst/fzf.kak" config %{
#   map -docstring "FZF" global user f ": fzf-mode<ret>"
# } defer fzf %{
#   set-option global fzf_tmux_popup true
#   set-option global fzf_preview false
#   set-option global fzf_tmux_popup_width '85%'
# } defer fzf-file %{
#   set-option global fzf_file_command "fd -LH -t f -E /.git"
#   set-option global fzf_highlight_command 'bat'
# } defer fzf-grep %{
#   set-option global fzf_grep_command "rg"
# }

define-command fuzzy-find-file -docstring "Find file" -params .. %{
  evaluate-commands %sh{
    file="$(rg --files |TMUX="${kak_client_env_TMUX}" fzf-tmux -p 90%,90% --preview="bat {}")"
    if [ -n "$file" ]; then
      printf 'edit "%s"\n' "$file"
    fi
  }
}

define-command fuzzy-find-file-all -docstring "Find file (all)" -params .. %{
  evaluate-commands %sh{
    file="$(find . -type f |TMUX="${kak_client_env_TMUX}" fzf-tmux -p 90%,90% --preview="bat {}")"
    if [ -n "$file" ]; then
      printf 'edit "%s"\n' "$file"
    fi
  }
}

define-command fuzzy-find-buffer -docstring "Switch to a buffer" %{
  evaluate-commands %sh{
    BUFFER=$(eval set -- "$kak_buflist"; for buf in "$@"; do echo "$buf"; done | \
    fzf-tmux -p 70%,50%)
    [ -n "$BUFFER" ] && echo "eval -client '$kak_client' 'buffer $BUFFER'" | kak -p "$kak_session"
  }
}
