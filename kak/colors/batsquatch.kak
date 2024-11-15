# One Dark

# core colors
declare-option str fg "c0caf5"
declare-option str bg "24283b"
declare-option str subbg "1f2335"

# code colors
declare-option str emphasis_light "5f6996"
declare-option str emphasis_medium "7e8dcc"
declare-option str emphasis_heavy "8a9be6"
declare-option str blue "7aa2f7"

# UI colors
declare-option str red "f7768e"
declare-option str orange "ff9e64"
declare-option str yellow "e0af68"
declare-option str light_green "9ece6a"
declare-option str green "73daca"
declare-option str aqua "2ac3de"
declare-option str teal "1abc9c"
declare-option str turquoise "89ddff"
declare-option str light_cyan "b4f9f8"
declare-option str cyan "7dcfff"
declare-option str purple "9d7cd8"
declare-option str magenta "bb9af7"
declare-option str black "414868"
declare-option str comment "5f6996"

declare-option str selectionalpha "35"

# Menus do not support transparency, so we must hardcode the selection + sub bg colors
declare-option str menuselection "3f5369"

# CODE

set-face global value "rgb:%opt{fg}"
set-face global type "rgb:%opt{blue}"
set-face global variable "rgb:%opt{fg}"
set-face global module "rgb:%opt{fg}"
set-face global function "rgb:%opt{emphasis_medium}"
set-face global string "rgb:%opt{blue}"
set-face global keyword "rgb:%opt{emphasis_medium}"
set-face global operator "rgb:%opt{fg}"
set-face global attribute "rgb:%opt{emphasis_light}"
set-face global comment "rgb:%opt{emphasis_light}"
set-face global documentation "rgb:%opt{emphasis_light}"
set-face global meta "rgb:%opt{fg}"
set-face global builtin "rgb:%opt{blue}"

# MARKUP

set-face global title "rgb:%opt{orange}"
set-face global header "rgb:%opt{green}"
set-face global mono "rgb:%opt{cyan}"
set-face global block "rgb:%opt{magenta}"
set-face global link "rgb:%opt{blue}"
set-face global bullet "rgb:%opt{orange}"
set-face global list "rgb:%opt{fg}"

# BUILTIN

set-face global Default "rgb:%opt{fg},rgb:%opt{bg}"
set-face global PrimarySelection "default,rgba:%opt{blue}%opt{selectionalpha}"
set-face global SecondarySelection "default,rgba:%opt{aqua}%opt{selectionalpha}"
set-face global PrimaryCursor "rgb:%opt{bg},rgb:%opt{blue}"
set-face global SecondaryCursor "rgb:%opt{bg},rgb:%opt{aqua}"
set-face global PrimaryCursorEol "rgb:%opt{bg},rgb:%opt{light_cyan}"
set-face global SecondaryCursorEol "rgb:%opt{bg},rgb:%opt{cyan}"
set-face global LineNumbers "rgb:%opt{comment}"
set-face global LineNumberCursor "rgb:%opt{comment}"
set-face global LineNumbersWrapped "rgb:%opt{bg},rgb:%opt{bg}"
set-face global MenuForeground "rgb:%opt{fg},rgb:%opt{menuselection}"
set-face global MenuBackground "rgb:%opt{fg},rgb:%opt{subbg}"
set-face global MenuInfo "rgb:%opt{green}"
set-face global Information "rgb:%opt{fg},rgb:%opt{subbg}"
set-face global Error "rgb:%opt{red}"
set-face global StatusLine "rgb:%opt{fg},rgb:%opt{subbg}"
set-face global StatusLineMode "rgb:%opt{orange}"
set-face global StatusLineInfo "rgb:%opt{blue}"
set-face global StatusLineValue "rgb:%opt{fg}"
set-face global StatusCursor "rgb:%opt{bg},rgb:%opt{blue}"
set-face global Prompt "rgb:%opt{blue}"
set-face global MatchingChar +bu
set-face global BufferPadding "rgb:%opt{bg},rgb:%opt{bg}"
set-face global Whitespace "rgb:%opt{comment}"

# PLUGINS

# kak-lsp
set-face global InlayHint "+d@type"
set-face global parameter "+i@variable"
set-face global enum "rgb:%opt{cyan}"
set-face global InlayDiagnosticError "rgb:%opt{red}"
set-face global InlayDiagnosticWarning "rgb:%opt{orange}"
set-face global InlayDiagnosticInfo "rgb:%opt{blue}"
set-face global InlayDiagnosticHint "rgb:%opt{green}"
set-face global LineFlagError "rgb:%opt{red}"
set-face global LineFlagWarning "rgb:%opt{orange}"
set-face global LineFlagInfo "rgb:%opt{blue}"
set-face global LineFlagHint "rgb:%opt{green}"
set-face global DiagnosticError ",,rgb:%opt{red}+c"
set-face global DiagnosticWarning ",,rgb:%opt{orange}+c"
set-face global DiagnosticInfo ",,rgb:%opt{blue}+c"
set-face global DiagnosticHint ",,rgb:%opt{green}+c"
# Infobox faces
set-face global InfoDefault Information
set-face global InfoBlock block
set-face global InfoBlockQuote block
set-face global InfoBullet bullet
set-face global InfoHeader header
set-face global InfoLink link
set-face global InfoLinkMono header
set-face global InfoMono mono
set-face global InfoRule comment
set-face global InfoDiagnosticError InlayDiagnosticError
set-face global InfoDiagnosticHint InlayDiagnosticHint
set-face global InfoDiagnosticInformation InlayDiagnosticInfo
set-face global InfoDiagnosticWarning InlayDiagnosticWarning

# kak-rainbower
# try %{ set-option global rainbow_colors "rgb:%opt{lightorange}" "rgb:%opt{magenta}" "rgb:%opt{blue}" }

# For backwards compatibility
# define-command -override -hidden one-enable-fancy-underlines %{
#     echo -debug "one-enable-fancy-underlines is deprecated - curly underlines are enabled by default"
# }
