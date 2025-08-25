return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      vim.lsp.enable({
        "elixirls",
        "gopls",
        "lua_ls",
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = require("lspconfig")

      lspconfig["elixirls"].setup({ capabilities = capabilities })
      lspconfig["lua_ls"].setup({ capabilities = capabilities })
      lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = {
          gopls = {
            completeUnimported = true,
            usePlaceholders = true,
          },
        },
      })
    end,
  },
}
