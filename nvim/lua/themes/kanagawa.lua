return {
  "rebelot/kanagawa.nvim",
  config = function()
    require("kanagawa").setup({
      transparent = false,
      dimInactive = true,
    })
  end,
}
