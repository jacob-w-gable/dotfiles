return {
  "dgrbrady/nvim-docker",
  -- Turned off. Set this back to true to get the container list on <leader>C
  -- again; lazy.nvim then skips installing and loading the plugin entirely.
  enabled = false,
  requires = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  rocks = "4O4/reactivex",
  config = function()
    local nvim_docker = require("nvim-docker")
    vim.keymap.set("n", "<leader>C", nvim_docker.containers.list_containers, { desc = "List Docker containers" })
  end,
}
