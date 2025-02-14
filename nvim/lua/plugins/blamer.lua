return {
  'APZelos/blamer.nvim',
  config = function()
    vim.g.blamer_enabled = 1
    vim.g.blamer_delay = 500
    vim.g.blamer_show_in_insert_modes = 1
    vim.g.blamer_prefix = ' > '
  end
}
