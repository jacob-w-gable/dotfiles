return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  opts = function(_, opts)
    if vim.g.no_glyphs then
      opts.default_component_configs = opts.default_component_configs or {}
      opts.default_component_configs.icon = { folder_closed = "[+]", folder_open = "[-]", default = " " }
      opts.default_component_configs.git_status = {
        symbols = {
          added = "+",
          modified = "~",
          deleted = "x",
          renamed = "r",
          untracked = "?",
          ignored = "i",
          unstaged = "!",
          staged = "s",
          conflict = "c",
        },
      }
    end
  end,
}
