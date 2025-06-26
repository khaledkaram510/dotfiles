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

-- VSCode function to register a command with Neovim and VSpaceCode
M.vscode_neovim_cmd = function(name, action, vscode_cmd)
  -- Create the Neovim command
  vim.api.nvim_create_user_command(name, function()
    vim.fn.VSCodeNotify(vscode_cmd or action)
  end, {})
  
  -- Return a function that can be used in keymaps
  return function()
    vim.fn.VSCodeNotify(action)
  end
end

-- Helper function for reliable leader key commands in VSCode
M.leader_cmd = function(cmd)
  -- This function helps ensure leader commands work in VSCode
  -- by using the correct key sequence even if intercepted
  if vim.g.vscode then
    -- When in VSCode, we need to be careful with leader key commands
    -- Check if we're already mid-key sequence (indicated by neovim.init context)
    local is_mid_sequence = vim.b.vscode_mid_sequence or false
    
    if is_mid_sequence then
      -- If we're in the middle of a key sequence, use leader directly
      return vim.api.nvim_replace_termcodes("<leader>" .. cmd, true, false, true)
    else
      -- If starting a new sequence, create a special VSpaceCode-aware command
      -- that can be mapped to alternate keys if needed
      return vim.api.nvim_replace_termcodes("<C-w>" .. cmd, true, false, true)
    end
  else
    -- In regular Neovim, just use leader as normal
    return vim.api.nvim_replace_termcodes("<leader>" .. cmd, true, false, true)
  end
end

M.map = function(mode, lhs, rhs, opts)
  opts = opts or {}
  opts.silent = false
  opts.noremap = true
  vim.keymap.set(mode, lhs, rhs, opts)
end

return M