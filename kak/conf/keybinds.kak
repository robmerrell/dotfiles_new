# hover
map global normal <c-h> ": lsp-hover<ret>"

# insert tab
map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'

# User mode
map -docstring "Leader" global user <space> ": enter-user-mode local-leader<ret>"
map -docstring "Buffer" global user b ": enter-user-mode buffer-management<ret>"
map -docstring "Comment line" global user c ": comment-line<ret>"
map -docstring "Easy motion" global user e ": enter-user-mode easymotion<ret>"
map -docstring "File" global user f ": enter-user-mode file-mode<ret>"
map -docstring "Harpoon" global user h ":enter-user-mode harpoon-nav-list<ret>"
map -docstring "LSP" global user l ": enter-user-mode lsp<ret>"
map -docstring "Paste the clipboard" global user p "<a-!> exec $SHELL -lc 'fish_clipboard_paste'<ret>"
map -docstring "Surround" global user s ": enter-user-mode surround<ret>"
map -docstring "Windows" global user w ": enter-user-mode window-management<ret>"
map -docstring "Yank to clipboard" global user y "<a-|> exec $SHELL -lc 'fish_clipboard_copy'<ret>"

# Files
declare-user-mode file-mode
map -docstring "Find file" global file-mode f ": fuzzy-find-file<ret>"
map -docstring "Find file (all)" global file-mode F ": fuzzy-find-file-all<ret>"
map -docstring "File tree" global file-mode t ": popup-find-file<ret>"
map -docstring "Search in files" global file-mode t ": live-grep<ret>"

# Local leader
declare-user-mode local-leader
map -docstring "Format JSON" global local-leader j "|jq .<ret>"
map -docstring "Open in Github" global local-leader g ": open-in-github<ret>"
map -docstring "Copy filename:linenumber" global local-leader l ": copy-git-relative-file<ret>"
map -docstring "Rerun test" global local-leader p ": rerun-tests<ret>"
map -docstring "Rerun right pane" global local-leader r ": rerun-right<ret>"
map -docstring "Rerun shell" global local-leader s ": rerun-shell<ret>"
map -docstring "Format XML" global local-leader x "|xmllint --format -<ret>"

# Buffer management
declare-user-mode buffer-management
map -docstring "Search in buffer" global buffer-management c ": buffer-previous<ret>"
map -docstring "Previous buffer" global buffer-management p ": buffer-previous<ret>"
map -docstring "Next buffer" global buffer-management n ": buffer-next<ret>"
map -docstring "Find buffer" global buffer-management s ": fuzzy-find-buffer<ret>"

# Window management
declare-user-mode window-management
map -docstring "Close" global window-management q ": q<ret>"
map -docstring "Split horizontally" global window-management s ": split<ret>"
map -docstring "Split vertically" global window-management v ": vsplit<ret>"
map -docstring "Select pane left" global window-management h %{: nop %sh{TMUX="${kak_client_env_TMUX}" tmux select-pane -L}<ret>}
map -docstring "Select pane down" global window-management j %{: nop %sh{TMUX="${kak_client_env_TMUX}" tmux select-pane -D}<ret>}
map -docstring "Select pane up" global window-management k %{: nop %sh{TMUX="${kak_client_env_TMUX}" tmux select-pane -U}<ret>}
map -docstring "Select pane right" global window-management l %{: nop %sh{TMUX="${kak_client_env_TMUX}" tmux select-pane -R}<ret>}

# Harpoon
declare-user-mode harpoon-nav-list
map -docstring "Nav to 1" global harpoon-nav-list 1 ": harpoon-nav 1<ret>"
map -docstring "Nav to 2" global harpoon-nav-list 2 ": harpoon-nav 2<ret>"
map -docstring "Nav to 3" global harpoon-nav-list 3 ": harpoon-nav 3<ret>"
map -docstring "Nav to 4" global harpoon-nav-list 4 ": harpoon-nav 4<ret>"
map -docstring "Nav to 5" global harpoon-nav-list 5 ": harpoon-nav 5<ret>"
map -docstring "Show all harpoons" global harpoon-nav-list h ": harpoon-show-list<ret>"
map -docstring "Add the current file to the list of harpoons" global harpoon-nav-list H ": harpoon-add<ret>"

# Lsp
declare-user-mode lsp-code
map -docstring "Actions" global lsp-code a ": lsp-code-actions<ret>"
map -docstring "Diagnostics" global lsp-code d ": lsp-diagnostics<ret>"
map -docstring "Find error" global lsp-code e ": lsp-find-error<ret>"
map -docstring "Hover" global lsp-code h ": lsp-hover-buffer<ret>"
map -docstring "Show documentation in buffer" global lsp-code K ": lsp-hover-buffer<ret>"
map -docstring "Document symbols" global lsp-code s ": lsp-document-symbol<ret>"

# Surround
declare-user-mode surround
map -docstring "Surround" global surround s ": surround<ret>" 
map -docstring "Change" global surround c ": change-surround<ret>" 
map -docstring "Delete" global surround d ": delete-surround<ret>" 
map -docstring "Select tag" global surround t ": select-surrounding-tag<ret>" 
