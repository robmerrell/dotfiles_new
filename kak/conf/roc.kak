plug "evanrelf/roc.kak"

hook global BufSetOption filetype=roc %{
  set-option buffer tabstop 4
  set-option buffer indentwidth 4
  hook buffer BufWritePre .* lsp-formatting-sync
}

hook -group lsp-filetype-elixir global BufSetOption filetype=roc %{
  set-option buffer lsp_servers %{
    [roc_language_server]
    command = "roc_language_server"
    root_globs = [".git"]
  }
}

