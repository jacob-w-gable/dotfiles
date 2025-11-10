return {
  "EdenEast/nightfox.nvim",
  config = function()
    -- Set the colorscheme
    require("nightfox").setup({
      options = {
        transparent = true,
        dim_inactive = false,
      },
    })
  end,
}
