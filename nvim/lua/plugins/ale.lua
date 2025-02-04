-- ALE is a plugin that gives fine-grained control over linters and formatters

return {
  "dense-analysis/ale",
  config = function()
    -- Configuration goes here.
    local g = vim.g

    g.ale_linters = {
      javascript = { "eslint", "prettier" },
      typescript = { "eslint", "prettier" },
      javascriptreact = { "eslint", "prettier" },
      typescriptreact = { "eslint", "prettier" },
      html = { "eslint", "prettier" },
      json = { "eslint", "prettier" },
      python = { "flake8", "mypy" },
    }

    g.ale_completion_enabled = 1

    g.ale_fix_on_save = 1
    g.ale_fixers = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      css = { "prettier" },
      markdown = { "prettier" },
      scss = { "prettier" },
      yaml = { "prettier" },
      python = { "autopep8" },
    }

    g.ale_python_flake8_executable = "flake8"
    g.ale_python_autopep8_executable = "autopep8"
    g.ale_python_mypy_executable = "mypy"
    g.ale_python_executable = "python3"
  end,
}
