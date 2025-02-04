-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Set the keymap for Ctrl + Backspace to delete the last word in insert mode
vim.api.nvim_set_keymap("i", "<C-H>", "<C-W>", { noremap = true, silent = true })
-- Set the keymap for Ctrl + del to delete the next word in insert mode
vim.api.nvim_set_keymap("i", "<C-Del>", "<C-O>dw", { noremap = true, silent = true })
-- Set the keymap for Ctrl + /
vim.api.nvim_set_keymap("n", "<C-t>", ":lua ToggleTerminal()<CR>", { noremap = true, silent = true })

-- Yank to system clipboard
vim.api.nvim_set_keymap("n", "y", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "y", '"+y', { noremap = true, silent = true })

-- Put from system clipboard
vim.api.nvim_set_keymap("n", "p", '"+p', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "P", '"+P', { noremap = true, silent = true })

-- Delete without affecting clipboard by using black hole register
vim.api.nvim_set_keymap("n", "d", '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "d", '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "D", '"_D', { noremap = true, silent = true })

-- Map Delete key to black hole register in normal and visual modes
vim.api.nvim_set_keymap("n", "<Del>", '"_x', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<Del>", '"_x', { noremap = true, silent = true })

-- Function to toggle terminal
function ToggleTerminal()
  local terminal_win = vim.t.terminal_win
  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    -- Terminal is open, close it
    vim.api.nvim_win_close(terminal_win, true)
    vim.t.terminal_win = nil
  else
    -- Terminal is not open, open it in a split
    vim.cmd("split")
    vim.cmd("terminal")
    vim.t.terminal_win = vim.api.nvim_get_current_win()
  end
end
