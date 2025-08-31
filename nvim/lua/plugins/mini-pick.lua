return {
  {
    "echasnovski/mini.pick",
    dependencies = { "echasnovski/mini.extra" },
    version = false,
    config = function()
      require("mini.pick").setup()
      require("mini.extra").setup()
    end,
  },
}
