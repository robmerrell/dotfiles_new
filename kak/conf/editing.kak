##### Autopairs #####
plug "alexherbo2/auto-pairs.kak" config %{
  set-option global auto_pairs ( ) { } [ ] '"' '"' "'" "'" ` ` “ ” ‘ ’ « » ‹ ›
  enable-auto-pairs
}

##### Surround #####
plug "https://github.com/h-youhei/kakoune-surround" config %{}

##### Easymotion #####
plug "https://git.sr.ht/~voroskoi/easymotion.kak" config %{
	require-module easymotion
}

##### Harpoon #####
plug "https://github.com/raiguard/kak-harpoon" config %{}

