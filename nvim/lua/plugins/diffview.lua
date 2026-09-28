-- Review the current branch against origin/main: every changed file in a sidebar, hunks on the
-- right. Both keys diff from the merge base with origin/main, the same range a merge request
-- shows, as of the last fetch.

-- Close the view when this tab is one, otherwise open one from `args`.
local function toggle(args)
  if require("diffview.lib").get_current_view() then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen " .. args)
  end
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    {
      "<leader>gm",
      function()
        toggle("origin/main...HEAD")
      end,
      desc = "Toggle branch vs origin/main diff, commits only (Diffview)",
    },
    {
      "<leader>gM",
      function()
        -- A single rev diffs against the working tree, so staged and unstaged edits show too.
        local base = vim.trim(vim.fn.system({ "git", "merge-base", "origin/main", "HEAD" }))
        if vim.v.shell_error ~= 0 then
          vim.notify("git merge-base origin/main HEAD failed: " .. base, vim.log.levels.ERROR)
          return
        end
        toggle(base)
      end,
      desc = "Toggle branch vs origin/main diff, with uncommitted changes (Diffview)",
    },
  },
}
