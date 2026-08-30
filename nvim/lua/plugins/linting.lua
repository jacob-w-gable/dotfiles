-- Linting, layered onto LazyVim's nvim-lint spec.
--
-- Only linters that are installed belong here. nvim-lint reports ENOENT on
-- every buffer of a matching filetype when a linter is missing, so registering
-- one that cannot run is worse than leaving it out. eslint_d is the notable
-- absence: add it back once it is installed.

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "flake8", "mypy" },
        markdown = { "markdownlint" },
      },
    },
  },
}
