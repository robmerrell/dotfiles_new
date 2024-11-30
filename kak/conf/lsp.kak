eval %sh{kak-lsp}
hook global WinSetOption filetype=(?:elixir|go) %{
	lsp-enable-window
	set-option global lsp_snippet_support true
}
