return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Tree
      require("nvim-tree").setup({
        git = {
          enable = false,
        },
        view = {
          width = 50,
        },
      })
    end,
  },
}
