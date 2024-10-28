eval %sh{kak-lsp}
hook global WinSetOption filetype=(?:elixir|go) %{
	lsp-enable-window
}
