-- Formatting, layered onto LazyVim's conform.nvim spec.
--
-- prettierd is the globally installed one, and it resolves each project's own
-- prettier version, so a project that vendors its own gets that one. Plain
-- prettier is the fallback for a project that ships it in node_modules on a
-- machine where prettierd is absent.

--- prettier through the daemon, falling back to the one-shot binary.
local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = prettier,
        javascriptreact = prettier,
        typescript = prettier,
        typescriptreact = prettier,
        html = prettier,
        json = prettier,
        css = prettier,
        scss = prettier,
        yaml = prettier,
        markdown = prettier,
        python = { "autopep8" },
      },
    },
  },
}
