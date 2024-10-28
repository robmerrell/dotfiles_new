plug "andreyorst/fzf.kak" config %{
  map -docstring "FZF" global user f ": fzf-mode<ret>"
} defer fzf %{
  set-option global fzf_tmux_popup true
  set-option global fzf_preview false
  set-option global fzf_tmux_popup_width '85%'
} defer fzf-file %{
  set-option global fzf_file_command "fd -LH -t f -E /.git"
  set-option global fzf_highlight_command 'bat'
} defer fzf-grep %{
  set-option global fzf_grep_command "rg"
}

