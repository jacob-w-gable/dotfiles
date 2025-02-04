return {
  "catppuccin/nvim",
  config = function()
    require("catppuccin").setup({
      flavour = "macchiato",
      transparent_background = false,
      term_colors = true,
      default_integrations = true,
    })
  end,
}
