-- Review the current branch against main: every changed file in a sidebar, hunks on the right.
-- Three dots diff against the merge base, the same range a merge request shows.
return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>gm", "<cmd>DiffviewOpen main...HEAD<cr>", desc = "Diff branch vs main (Diffview)" },
  },
}
