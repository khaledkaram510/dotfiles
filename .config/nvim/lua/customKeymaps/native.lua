-- Native Neovim keymaps
local M = {}

M.setup = function()
  local utils = require('customKeymaps.utils')
  local map = utils.map
  -- Clear highlights with escape
  map('n', '<Esc>', utils.clear_highlights)

  -- Terminal escape
  map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- Window navigation
  map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
  map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
  map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
  map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

  -- Diagnostic keymaps
  map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- LSP keymaps with lazy loading of telescope
  map('n', 'grn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' })
  map('n', 'gra', vim.lsp.buf.code_action, { desc = '[G]oto Code [A]ction' })
  map('n', 'grr', function() require('telescope.builtin').lsp_references() end, { desc = '[G]oto [R]eferences' })
  map('n', 'grd', function() require('telescope.builtin').lsp_definitions() end, { desc = '[G]oto [D]efinition' })
  map('n', 'gri', function() require('telescope.builtin').lsp_implementations() end, { desc = '[G]oto [I]mplementation' })
  map('n', 'grt', function() require('telescope.builtin').lsp_type_definitions() end, { desc = '[G]oto [T]ype Definition' })

  -- Telescope keymaps with lazy loading
  map('n', '<leader>sh', function() require('telescope.builtin').help_tags() end, { desc = '[S]earch [H]elp' })
  map('n', '<leader>sk', function() require('telescope.builtin').keymaps() end, { desc = '[S]earch [K]eymaps' })
  map('n', '<leader>sf', function() require('telescope.builtin').find_files() end, { desc = '[S]earch [F]iles' })
  map('n', '<leader>sg', function() require('telescope.builtin').live_grep() end, { desc = '[S]earch by [G]rep' })
  map('n', '<leader>sd', function() require('telescope.builtin').diagnostics() end, { desc = '[S]earch [D]iagnostics' })
  map('n', '<leader>sr', function() require('telescope.builtin').resume() end, { desc = '[S]earch [R]esume' })
  map('n', '<leader>s.', function() require('telescope.builtin').oldfiles() end, { desc = '[S]earch Recent Files' })
  map('n', '<leader><leader>', function() require('telescope.builtin').buffers() end, { desc = '[ ] Find existing buffers' })

  -- Buffer/File operations
  map('n', '<leader>w', utils.write_buffer, { desc = '[W]rite file' })
  map('n', '<leader>q', utils.quit_buffer, { desc = '[Q]uit' })
  map('n', '<leader>bd', utils.delete_buffer, { desc = '[B]uffer [D]elete' })
end

return M