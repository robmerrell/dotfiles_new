hook global BufSetOption filetype=elixir %{
  hook buffer BufWritePre .* lsp-formatting-sync
}

hook -group lsp-filetype-elixir global BufSetOption filetype=elixir %{
  set-option buffer lsp_servers %{
    [elixir-ls]
    command = "language_server.sh"
    # root_globs = ["mix.exs", "mix.lock"]
    root_globs = ["mix.lock", "mix.exs"]
    settings_section = "elixirLS"
    [elixir-ls.settings.elixirLS]
    # See https://github.com/elixir-lsp/elixir-ls/blob/master/apps/language_server/lib/language_server/server.ex
    dialyzerEnable = true
  }
}

