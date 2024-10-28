hook global BufSetOption filetype=go %{
  set-option global tabstop 4
  hook buffer BufWritePre .* lsp-formatting-sync
}
