local M = {}

-- Common functions used in both VSCode and native Neovim
M.clear_highlights = function()
  vim.cmd('nohlsearch')
end

M.write_buffer = function()
  vim.cmd('w')
end

M.quit_buffer = function()
  vim.cmd('q')
end

M.delete_buffer = function()
  vim.cmd('bd')
end

-- VSCode specific functions
M.vscode_notify = function(action)
  vim.fn.VSCodeNotify(action)
end

M.map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = false
  opts.noremap = true
  vim.keymap.set(mode, lhs, rhs, opts)
end

return M