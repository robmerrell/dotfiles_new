hook global BufSetOption filetype=go %{
  set-option buffer tabstop 4
  set-option buffer indentwidth 4 
  hook buffer BufWritePre .* lsp-formatting-sync
}
