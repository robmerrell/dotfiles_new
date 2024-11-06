# User mode
map -docstring "Leader" global user <space> ": enter-user-mode local-leader<ret>"
map -docstring "Buffer" global user b ": enter-user-mode buffer-management<ret>"
map -docstring "Comment line" global user c ": comment-line<ret>"
map -docstring "Easy motion" global user e ": enter-user-mode easymotion<ret>"
map -docstring "Find" global user f ": fzf-mode<ret>"
map -docstring "Harpoon" global user h ":enter-user-mode harpoon-nav-list<ret>"
map -docstring "LSP" global user l ": enter-user-mode lsp-code<ret>"
map -docstring "Paste the clipboard" global user p "<a-!> exec $SHELL -lc 'fish_clipboard_paste'<ret>"
map -docstring "Surround" global user s ": enter-user-mode surround<ret>"
map -docstring "Windows" global user w ": enter-user-mode window-management<ret>"
map -docstring "Yank to clipboard" global user y "<a-|> exec $SHELL -lc 'fish_clipboard_copy'<ret>"

# Local Leader
declare-user-mode local-leader
map -docstring "Copy filename:linenumber" global local-leader p ": buffer-previous<ret>"

# Buffer management
declare-user-mode buffer-management
map -docstring "Previous Buffer" global buffer-management p ": buffer-previous<ret>"
map -docstring "Next Buffer" global buffer-management n ": buffer-next<ret>"

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
map -docstring "Nav To 1" global harpoon-nav-list 1 ": harpoon-nav 1<ret>"
map -docstring "Nav To 2" global harpoon-nav-list 2 ": harpoon-nav 2<ret>"
map -docstring "Nav To 3" global harpoon-nav-list 3 ": harpoon-nav 3<ret>"
map -docstring "Nav To 4" global harpoon-nav-list 4 ": harpoon-nav 4<ret>"
map -docstring "Nav To 5" global harpoon-nav-list 5 ": harpoon-nav 5<ret>"
map -docstring "Show all harpoons" global harpoon-nav-list h ": harpoon-show-list<ret>"
map -docstring "Add the current file to the list of harpoons" global harpoon-nav-list H ": harpoon-add<ret>"

# Lsp
declare-user-mode lsp-code
map -docstring "Actions" global lsp-code a ": lsp-code-actions<ret>"
map -docstring "Diagnostics" global lsp-code d ": lsp-diagnostics<ret>"
map -docstring "Find error" global lsp-code e ": lsp-find-error<ret>"
map -docstring "Hover" global lsp-code h ": lsp-hover<ret>"
map -docstring "Show documentation in buffer" global lsp-code K ": lsp-hover-buffer<ret>"
map -docstring "Document symbols" global lsp-code s ": lsp-document-symbol<ret>"

# Surround
declare-user-mode surround
map -docstring "Surround" global surround s ": surround<ret>" 
map -docstring "Change" global surround c ": change-surround<ret>" 
map -docstring "Delete" global surround d ": delete-surround<ret>" 
map -docstring "Select tag" global surround t ": select-surrounding-tag<ret>" 
