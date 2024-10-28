hook global BufSetOption filetype=elixir %{
  hook buffer BufWritePre .* lsp-formatting-sync
}
