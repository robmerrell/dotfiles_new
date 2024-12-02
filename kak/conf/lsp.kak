eval %sh{kak-lsp}
hook global WinSetOption filetype=(?:elixir|go|roc) %{
	lsp-enable-window
	set-option global lsp_snippet_support true
	lsp-inlay-hints-enable global
}
