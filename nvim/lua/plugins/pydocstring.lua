return {
  "heavenshell/vim-pydocstring",
  build = "make install",
  ft = "python",
  config = function()
    vim.g.pydocstring_templates_path = "~/dotfiles/nvim/pydocstring-templates"
  end,
}
