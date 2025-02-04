return {
  "dgrbrady/nvim-docker",
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
