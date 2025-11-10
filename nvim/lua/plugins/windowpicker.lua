return {
  "s1n7ax/nvim-window-picker",
  name = "window-picker",
  event = "VeryLazy",
  version = "2.*",
  config = function()
    require("window-picker").setup({
      highlights = {
        statusline = {
          focused = {
            fg = "#1e1e2e",
            bg = "#89b4fa",
            bold = true,
          },
          unfocused = {
            fg = "#cdd6f4",
            bg = "#313244",
          },
        },
      },
    })
  end,
}
