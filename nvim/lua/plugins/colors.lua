return {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "AlexvZyl/nordic.nvim", lazy = false, priority = 1000 },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd.colorscheme("tokyonight-storm")
    end,
  },
}
