-- Native Neovim configuration
local M = {}

M.setup = function()
  -- Basic options
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.scrolloff = 10
  vim.opt.clipboard = 'unnamedplus'
  vim.opt.timeoutlen = 300

  -- Native-specific options
  vim.opt.number = true
  vim.opt.breakindent = true
  vim.opt.undofile = true
  vim.opt.signcolumn = 'yes'
  vim.opt.splitright = true
  vim.opt.splitbelow = true
  vim.opt.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
  vim.opt.inccommand = 'split'
  vim.opt.cursorline = true

  -- Load native-specific keymaps
  require('customKeymaps.native').setup()

  -- Plugin configuration for native Neovim
  require('lazy').setup({
    -- Common plugins
    'tpope/vim-sleuth',

    -- Mini.nvim with full configuration
    {
      'echasnovski/mini.nvim',
      config = function()
        require('mini.ai').setup { n_lines = 500 }
        require('mini.surround').setup()
        
        -- Statusline (native only)
        local statusline = require 'mini.statusline'
        statusline.setup { use_icons = vim.g.have_nerd_font }
        statusline.section_location = function()
          return '%2l:%-2v'
        end
      end,
    },

    -- Telescope
    {
      'nvim-telescope/telescope.nvim',
      dependencies = {
        'nvim-lua/plenary.nvim',
        { 
          'nvim-telescope/telescope-fzf-native.nvim',
          build = 'make',
          cond = function()
            return vim.fn.executable 'make' == 1
          end,
        },
        'nvim-telescope/telescope-ui-select.nvim',
        { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      },
      config = function()
        require('telescope').setup {
          extensions = {
            ['ui-select'] = {
              require('telescope.themes').get_dropdown(),
            },
          },
        }
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'ui-select')
      end,
    },

    -- LSP Configuration
    {
      'neovim/nvim-lspconfig',
      dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        'mason-org/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        { 'j-hui/fidget.nvim', opts = {} },
        'saghen/blink.cmp',
      },
    },

    -- Autoformatting
    {
      'stevearc/conform.nvim',
      event = { 'BufWritePre' },
      cmd = { 'ConformInfo' },
      opts = {
        formatters_by_ft = {
          lua = { 'stylua' },
        },
      },
    },

    -- Completion
    {
      'saghen/blink.cmp',
      event = 'VimEnter',
      dependencies = {
        'L3MON4D3/LuaSnip',
        'folke/lazydev.nvim',
      },
    },

    -- Theme
    {
      'folke/tokyonight.nvim',
      priority = 1000,
      config = function()
        require('tokyonight').setup {
          styles = {
            comments = { italic = false },
          },
        }
        vim.cmd.colorscheme 'tokyonight-night'
      end,
    },

    -- Treesitter
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      main = 'nvim-treesitter.configs',
      opts = {
        ensure_installed = { 'lua', 'vim' },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      },
    },
  })
end

return M