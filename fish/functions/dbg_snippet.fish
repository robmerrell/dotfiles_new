# Outputs debug snippets for different languages
function dbg_snippet
    switch $argv[1]
        case elixir
            echo -n "limit: :infinity, printable_limit: :infinity"
        case python
            echo -n "__import__('pprint').pprint()"
    end
end
