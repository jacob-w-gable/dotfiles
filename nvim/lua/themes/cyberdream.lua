return {
  "scottmckendry/cyberdream.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- Set the colorscheme
    require("cyberdream").setup({
      transparent = true,
      borderless_telescope = false,
      saturation = 1,
      italic_comments = true,
      borderless_pickers = false,
      -- hide_fillchars = true,
    })
  end,
}
