-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Better quickfix list navigation
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix item" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix item" })

-- Escape terminal mode with jk
map("t", "jk", "<C-\\><C-n>", { desc = "Exit terminal mode" })
