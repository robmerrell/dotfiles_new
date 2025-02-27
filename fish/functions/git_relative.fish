# take an absolute filepath and get its relative path to .git
function git_relative
  if test -n "$argv[1]" -a -f "$argv[1]"
		set -l gitroot (git rev-parse --show-toplevel) || return 1
		set -l replaced (string replace $gitroot "./" $argv[1] | path normalize)
		echo -n $replaced
  else
    echo "Needs a valid file"
  end
end

