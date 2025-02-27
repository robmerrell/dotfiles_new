# Shows a tmux cheatsheet using glow
function cheat_tmux
  echo -n "
  # System
  `ctrl + a` Prefix
  `d` Detach Session
  `\$` Rename Session

  # Windows
  `c` Create Window
  `,` Rename Window
  `p` Previous Window
  `n` Next Window
  `&` Kill Window
 
  # Panes
  `q` Show Number
  `s` Split Horizontally
  `v` Split Vertically
  `h` Left Pane
  `j` Down Pane
  `k` Up Pane
  `l` Right Pane
  `x` Kill Pane" \
  | glow -s dracula
end
