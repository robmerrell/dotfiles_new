-- Base keybindings. Specific languages should define their own local keybindings.

-- I constantly press this by accident
vim.api.nvim_set_keymap("", "I", "<Nop>", { noremap = true, silent = true })

-- mapping helpers
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

-- top level
nmap_leader("n", "<Cmd>nohlsearch<CR>", "Remove Highlight")
nmap_leader("l", function()
  local filepath = vim.fn.expand("%")
  local lineno = vim.fn.line(".")
  vim.fn.setreg("+", filepath .. ":" .. lineno)
end, "Copy filename:lineno")

-- g mappings
vim.keymap.set("n", "gw", "<Cmd>HopWord<CR>", { desc = "Hop Word" })
vim.keymap.set("n", "gd", function()
  vim.lsp.buf.definition()
end, { desc = "Go To Definition" })

-- buffers
nmap_leader("bf", "<Cmd>Pick buf_lines<CR>", "Find In Buffer")
nmap_leader("bs", "<Cmd>Pick buffers<CR>", "Search Buffers")

-- file
nmap_leader("ff", "<Cmd>Pick files<CR>", "Find Files")
nmap_leader("fg", "<Cmd>Pick git_hunks<CR>", "Git Hunks")
nmap_leader("fo", function()
  MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
end, "Open File In Tree")
nmap_leader("ft", function()
  MiniFiles.open(nil, false)
end, "Open Tree")

-- search
nmap_leader("sl", "<Cmd>Pick grep_live<CR>", "Live Grep")

-- tab
nmap_leader("t1", "<Cmd>tabn 1<CR>", "Tab 1")
nmap_leader("t2", "<Cmd>tabn 2<CR>", "Tab 2")
nmap_leader("t3", "<Cmd>tabn 3<CR>", "Tab 3")
nmap_leader("t4", "<Cmd>tabn 4<CR>", "Tab 4")
nmap_leader("tc", "<Cmd>tabnew<CR>", "Create Tab")
nmap_leader("to", "<Cmd>tab split<CR>", "Open In New Tab")
nmap_leader("tp", "<Cmd>tabprevious<CR>", "←")
nmap_leader("tn", "<Cmd>tabnext<CR>", "→")
nmap_leader("tq", "<Cmd>tabclose<CR>", "Close Tab")

-- version control
nmap_leader("vb", "<Cmd>BlameToggle window<CR>", "Blame")
nmap_leader("vo", "<Cmd>OpenInGHFileLines<CR>", "Open in Github")

-- window
nmap_leader("w1", "<Cmd>1wincmd w<CR>", "Window 1")
nmap_leader("w2", "<Cmd>2wincmd w<CR>", "Window 2")
nmap_leader("w3", "<Cmd>3wincmd w<CR>", "Window 3")
nmap_leader("w4", "<Cmd>4wincmd w<CR>", "Window 4")
nmap_leader("wh", "<Cmd>wincmd h<CR>", "←")
nmap_leader("wj", "<Cmd>wincmd j<CR>", "↓")
nmap_leader("wk", "<Cmd>wincmd k<CR>", "↑")
nmap_leader("wl", "<Cmd>wincmd l<CR>", "→")
nmap_leader("wq", "<Cmd>wincmd q<CR>", "Close Window")
nmap_leader("ws", "<Cmd>split<CR>", "Split Horizontal")
nmap_leader("wv", "<Cmd>vsplit<CR>", "Split Vertical")

-- miniclue setup
local miniclue = require("mini.clue")
miniclue.setup({
  window = {
    delay = 500,
  },

  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = "\"" },
    { mode = "x", keys = "\"" },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },

  clues = {
    { mode = "n", keys = "<Leader>b", desc = "+Buffers" },
    { mode = "n", keys = "<Leader>f", desc = "+Files" },
    { mode = "n", keys = "<Leader>s", desc = "+Search" },
    { mode = "n", keys = "<Leader>t", desc = "+Tabs" },
    { mode = "n", keys = "<Leader>v", desc = "+Version Control" },
    { mode = "n", keys = "<Leader>w", desc = "+Windows" },
    { mode = "n", keys = "<Leader>n" },
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
})
