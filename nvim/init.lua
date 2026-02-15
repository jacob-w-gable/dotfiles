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

-- Temporary suppression of the `rust_analyzer: -32802: server cancelled the request` error message,
-- which happens when rust_analyzer can't keep up with keystrokes and starts debouncing.
-- See https://github.com/neovim/neovim/issues/30985
-- Neovim milestone 0.11 is due March 15th, 2025 and will have a fix for this issue.
-- for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
--   local default_diagnostic_handler = vim.lsp.handlers[method]
--   vim.lsp.handlers[method] = function(err, result, context, config)
--     if err ~= nil and err.code == -32802 then
--       return
--     end
--     return default_diagnostic_handler(err, result, context, config)
--   end
-- end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "vimwiki",
  callback = function()
    vim.bo.filetype = "markdown"
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*/diary/*.md",
  callback = function()
    local template_path = vim.fn.expand("~/Nextcloud/Documents/Notes/WorkDiary.md")
    if vim.fn.filereadable(template_path) == 1 then
      local lines = vim.fn.readfile(template_path)

      -- Generate a formatted header like "Monday, July 14, 2025"
      local date = os.date("*t")
      local formatted = os.date("%A, %B %d, %Y") -- e.g. "Monday, July 14, 2025"

      -- Replace first line (assumes it's the header)
      if #lines > 0 then
        lines[1] = "# " .. formatted
      end

      -- Insert lines into the buffer
      vim.api.nvim_buf_set_lines(0, 0, 0, false, lines)
    end
  end,
})
