return {
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          json = { "jq" },
        },
        format_on_save = {
          lsp_fallback = true,
        },
      })
    end,
  },
}
