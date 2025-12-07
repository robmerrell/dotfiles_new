# Starts a python tmux session
function proj_python
    set proj (basename $PWD)

    tmux new-session -d -s $proj
    tmux rename-window -t $proj:0 opencode
    tmux new-window -t $proj:1 -n repl
    tmux new-window -t $proj:2 -n tests
    tmux new-window -t $proj:3 -n shell
    tmux attach -t $proj
end
