return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = require("lspconfig")

      lspconfig["lua_ls"].setup({ capabilities = capabilities })

      lspconfig["elixirls"].setup({
        capabilities = capabilities,
        cmd = { "language_server.sh" },
      })

      lspconfig["gopls"].setup({
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
