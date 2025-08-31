return {
  {
    "echasnovski/mini.indentscope",
    version = "*",
    lazy = false,
    config = function()
      local scope = require("mini.indentscope")
      scope.setup({
        symbol = "│",
        draw = {
          animation = scope.gen_animation.none(),
        },
      })
    end,
  },
}
