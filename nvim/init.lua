-- bootstrap lazy.nvim, LazyVim and your plugins

-- Load lazy.nvim. Plugin loading is done by LazyVim
require("config.lazy")
-- Load custom keymaps
require("config.keymaps")
-- Load custom nvim options
require("config.options")
-- Load custom nvim commands
require("config.autocmds")
-- Load the chosen theme
require("config.theme")
-- Configure the LSP
require("config.lsp")

require("nvim-treesitter.configs").setup({
  ensure_installed = { "rust", "toml" },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  rainbow = {
    enable = true,
    extended_mode = true,
    max_file_lines = nil,
  },
})
