-- Formatting, layered onto LazyVim's conform.nvim spec.
--
-- conform resolves prettier through node_modules before PATH, so a project
-- that vendors its own version gets that one.

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        python = { "autopep8" },
      },
    },
  },
}
