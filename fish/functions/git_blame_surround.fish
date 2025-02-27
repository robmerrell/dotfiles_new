# retun the 5 surrounding lines for a git blame
function git_blame_surround
    if set -q argv[1] && set -q argv[2]
        set span 3
        set input_line (math $argv[2])

        # find the beginning and ending lines
        if test $input_line -gt $span
            set begin_line (math "$input_line - $span")
            set end_line (math "$input_line + $span")
        else
            set begin_line 0
            set end_line (math "$span * 2")
        end

        git blame -L $begin_line,$end_line $argv[1]
    else
        echo "Needs a file and a line number"
    end
end
