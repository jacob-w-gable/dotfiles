-- Review the current branch against main: every changed file in a sidebar, hunks on the right.
-- Three dots diff against the merge base, the same range a merge request shows.
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    {
      "<leader>gm",
      function()
        -- Toggle: close the view when this tab is one, otherwise open it.
        if require("diffview.lib").get_current_view() then
          vim.cmd("DiffviewClose")
        else
          vim.cmd("DiffviewOpen main...HEAD")
        end
      end,
      desc = "Toggle branch vs main diff (Diffview)",
    },
  },
}
