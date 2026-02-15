-- Set the theme here
vim.cmd("colorscheme cyberdream")
-- vim.cmd("colorscheme catppuccin") -- pink and purple pastel tints
-- vim.cmd("colorscheme synthwave84")
-- vim.cmd("colorscheme tokyonight")
-- vim.cmd("colorscheme habamax")
-- vim.cmd("colorscheme kanagawa") -- colorful, yellow vintage tint
-- vim.cmd("colorscheme carbonfox") -- blue-based theme
-- vim.cmd("colorscheme nightfox") -- colorful, but darker and more desaturated
-- vim.cmd("colorscheme aura-dark") -- bright green/teal/blues, some dark purples
-- vim.cmd("colorscheme onedark") -- solid generic colors

if vim.g.no_glyphs then
  vim.cmd.colorscheme("habamax")
  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
end

local function tty_patch()
  if not vim.g.no_glyphs then
    return
  end

  vim.opt.termguicolors = false

  -- Make Neo-tree hidden/dotfiles visible
  -- These group names vary slightly by version; set a few common ones.
  local groups = {
    "NeoTreeDotfile",
    "NeoTreeHiddenByName",
    "NeoTreeFileName",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
  }

  for _, g in ipairs(groups) do
    pcall(vim.api.nvim_set_hl, 0, g, { fg = "White", bg = "Black" })
  end

  -- Make the indent guides / expanders visible too
  pcall(vim.api.nvim_set_hl, 0, "NeoTreeIndentMarker", { fg = "Gray" })
  pcall(vim.api.nvim_set_hl, 0, "NeoTreeExpander", { fg = "Gray" })
  pcall(vim.api.nvim_set_hl, 0, "WinSeparator", { fg = "Gray", bg = "Black" })
  pcall(vim.api.nvim_set_hl, 0, "VertSplit", { fg = "Gray", bg = "Black" })
  pcall(vim.api.nvim_set_hl, 0, "CursorLine", { reverse = true })
  pcall(vim.api.nvim_set_hl, 0, "LineNr", { fg = "Gray" })
  pcall(vim.api.nvim_set_hl, 0, "CursorLineNr", { fg = "White", bold = true })
  pcall(vim.api.nvim_set_hl, 0, "LineNrAbove", { fg = "Gray" })
  pcall(vim.api.nvim_set_hl, 0, "LineNrBelow", { fg = "Gray" })
  pcall(vim.api.nvim_set_hl, 0, "NeoTreeCursorLine", { link = "CursorLine" })
  pcall(vim.api.nvim_set_hl, 0, "NeoTreeCursorLineNC", { link = "CursorLine" })
  pcall(vim.api.nvim_set_hl, 0, "Comment", { fg = "DarkGray" })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = tty_patch })
vim.api.nvim_create_autocmd("VimEnter", { callback = tty_patch })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "neo-tree",
  callback = function()
    if not vim.g.no_glyphs then
      return
    end
    vim.opt_local.cursorline = true
  end,
})
