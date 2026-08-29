-- Linting, via LazyVim's nvim-lint.
--
-- Replaces ALE's linters. Three entries from that config are deliberately not
-- carried over:
--
--   prettier   was listed as a *linter* for js/ts/html/json. ALE has no such
--              linter and silently ignored it.
--   eslint     for html needs a plugin that was never configured.
--   eslint_d   is installed nowhere, and unlike ALE -- which skipped a missing
--              linter in silence -- nvim-lint reports ENOENT on every JS/TS
--              buffer. Registering a linter that cannot run is worse than not
--              registering it. Add it back here once eslint_d is installed.

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
