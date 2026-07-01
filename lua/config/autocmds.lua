-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local group = vim.api.nvim_create_augroup("user_autocmds", { clear = true })

-- Auto-create parent directories when saving a new file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = group,
  pattern = "*",
  callback = function(event)
    local file = vim.uv.fs_realpath(event.match)
    if not file then
      local dir = vim.fn.fnamemodify(event.match, ":h")
      vim.uv.fs_mkdir(dir, tonumber("755", 8))
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Resize splits when the window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  pattern = "*",
  callback = function()
    local cw = vim.fn.winwidth(0)
    if cw > 120 then
      vim.cmd("wincmd =")
    end
  end,
})
