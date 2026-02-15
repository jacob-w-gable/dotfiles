return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local section_left = ""
    local section_right = ""
    local component_left = ""
    local component_right = ""
    local theme = "auto"
    local icons_enabled = true
    local clock = "  %H:%M"

    if vim.g.no_glyphs then
      section_left = ""
      section_right = ""
      component_left = "|"
      component_right = "|"
      theme = "16color"
      icons_enabled = false
      clock = "%H:%M"
    end

    require("lualine").setup({
      options = {
        icons_enabled = icons_enabled,
        theme = theme,
        section_separators = { left = section_left, right = section_right },
        component_separators = { left = component_left, right = component_right },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", file_status = true, newfile_status = true, path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress", "location" },
        lualine_z = { { "datetime", style = clock } },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = { "mason", "neo-tree", "trouble" },
    })
  end,
}
