return {
  "EdenEast/nightfox.nvim",
  config = function()
    -- Set the colorscheme
    require("nightfox").setup({
      options = {
        transparent = false,
        dim_inactive = true,
      },
    })
  end,
}
