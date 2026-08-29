-- Formatting, via LazyVim's conform.nvim.
--
-- These filetypes were previously fixed by ALE's fix_on_save. ALE ran on
-- BufWritePost, after conform had already formatted and written on
-- BufWritePre, so every save formatted twice and wrote the file twice.
--
-- conform resolves prettier through node_modules first (util.from_node_modules),
-- so project-local installs keep working exactly as they did under ALE.

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
