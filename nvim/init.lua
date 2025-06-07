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

require("cmp").setup({
  formatting = {
    format = require("nvim-highlight-colors").format,
  },
})

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

-- Temporary suppression of the `rust_analyzer: -32802: server cancelled the request` error message,
-- which happens when rust_analyzer can't keep up with keystrokes and starts debouncing.
-- See https://github.com/neovim/neovim/issues/30985
-- Neovim milestone 0.11 is due March 15th, 2025 and will have a fix for this issue.
for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
  local default_diagnostic_handler = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function(err, result, context, config)
    if err ~= nil and err.code == -32802 then
      return
    end
    return default_diagnostic_handler(err, result, context, config)
  end
end
