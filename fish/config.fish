# env vars
set -gx HELIX_RUNTIME $HOME/projects/gh/helix/runtime
set -gx SKIM_DEFAULT_COMMAND rg --files

# fzf settings
set -x FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS \
    "--highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none
  --color=bg+:#2e3c64 \
  --color=bg:#1f2335 \
  --color=border:#29a4bd \
  --color=fg:#c0caf5 \
  --color=gutter:#1f2335 \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#29a4bd \
  --color=separator:#ff9e64 \
  --color=spinner:#ff007c"

# aliases
alias vi='nvim'
alias vim='nvim'

# paths
set -x GOPATH $HOME/go
set -x PATH $PATH $GOPATH/bin
set -x PATH $PATH $HOME/.cargo/bin
set -x PATH $PATH $HOME/bin
set -x PATH $PATH $HOME/projects/gh/elixir-ls
set -x PATH $PATH $HOME/projects/gh/roc_nightly
set -x PATH $PATH $HOME/.local/share/bob/nvim-bin

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# ASDF configuration code
if test -z $ASDF_DATA_DIR
    set _asdf_shims "$HOME/.asdf/shims"
else
    set _asdf_shims "$ASDF_DATA_DIR/shims"
end

# Do not use fish_add_path (added in Fish 3.2) because it
# potentially changes the order of items in PATH
if not contains $_asdf_shims $PATH
    set -gx --prepend PATH $_asdf_shims
end
set --erase _asdf_shims

switch (uname)
    case Linux
        # source ~/.asdf/asdf.fish
        set -gx TMUX_TMPDIR /tmp
    case Darwin
        set -x PATH $PATH /opt/homebrew/bin
        # source /opt/homebrew/opt/asdf/libexec/asdf.fish
        set -x PATH $PATH /Applications/Postgres.app/Contents/Versions/16/bin
end
