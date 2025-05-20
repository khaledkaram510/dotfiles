-- VSCode Neovim configuration
local M = {}

M.setup = function()
  -- Basic options that work well in VSCode
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.scrolloff = 15
  vim.opt.clipboard = 'unnamedplus'
  vim.opt.timeoutlen = 300
  
  -- Function to run Neovim commands in terminal split
  local function create_terminal_command(name, cmd)
      vim.api.nvim_create_user_command(name, function()
          vim.cmd('vsplit')
          vim.cmd(string.format('terminal nvim --headless -c "%s" -c "quit"', cmd))
          vim.cmd('vertical resize 80')
          -- Make the terminal buffer non-modifiable
          vim.bo.modifiable = false
      end, {})
  end

  -- Create terminal commands for common Neovim commands
  create_terminal_command('CheckHealth', 'checkhealth')
  create_terminal_command('Messages', 'messages')
  create_terminal_command('Version', 'version')
  create_terminal_command('Registers', 'registers')

  -- You can add more commands here using the same pattern:
  -- create_terminal_command('CommandName', 'original_command')


  -- Plugin configuration for VSCode
  require('lazy').setup({
    -- Common plugins that work in VSCode
    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

    {
      "folke/flash.nvim",
      event = "VeryLazy",
      opts = {},
    }, 
    
    -- Multiple cursors support
    {
      "jake-stewart/multicursor.nvim",
      branch = "1.0",
      lazy = false, -- Load immediately to ensure it's available for keymaps
      config = function()
        require("multicursor-nvim").setup()
      end
    },

    -- Better f/t motions
    {
      'ggandor/flit.nvim',
      dependencies = { 'ggandor/leap.nvim' },
      config = function()
        require('flit').setup()
      end
    },

    -- Enhanced increment/decrement
    {
      'monaqa/dial.nvim',
      config = function()
        local augend = require("dial.augend")
        require("dial.config").augends:register_group{
          default = {
            augend.integer.alias.decimal,
            augend.integer.alias.hex,
            augend.date.alias["%Y/%m/%d"],
            augend.constant.alias.bool,
          },
        }
      end,
      -- Keymaps moved to customKeymaps/vscode.lua
    },

    -- Better yank history
    {
      'gbprod/yanky.nvim',
      config = function()
        require('yanky').setup({
          highlight = { timer = 250 },
        })
      end,
    },
    
    -- Mini.nvim modules that work well in VSCode
    {
      'echasnovski/mini.nvim',
      config = function()
        -- Text objects
        require('mini.ai').setup { n_lines = 500 }
        -- Surround functionality
        require('mini.surround').setup()
        -- Auto pairs
        require('mini.pairs').setup()
        -- Comments
        require('mini.comment').setup()
        -- Move text up/down
        require('mini.move').setup()
      end,
    },

    -- Treesitter configuration
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      config = function()
        require('nvim-treesitter.configs').setup {
          ensure_installed = { 
            'lua', 'vim', 'javascript', 'typescript', 'python', 
            'bash', 'markdown', 'markdown_inline' 
          },
          highlight = { enable = false }, -- VSCode handles highlighting
          indent = { enable = false }, -- VSCode handles indenting

          incremental_selection = {
            enable = true,
            -- Keymaps moved to customKeymaps/vscode.lua
          },

          textobjects = {
            select = {
              enable = true,
              lookahead = true,
              include_surrounding_whitespace = false,
              keymaps = {
                -- Visual mode text objects
                ["aF"] = { query = "@function.outer", desc = "Select outer function" },
                ["iF"] = { query = "@function.inner", desc = "Select inner function" },
                ["aC"] = { query = "@class.outer", desc = "Select outer class" },
                ["iC"] = { query = "@class.inner", desc = "Select inner class" },
                ["aA"] = { query = "@parameter.outer", desc = "Select outer parameter" },
                ["iA"] = { query = "@parameter.inner", desc = "Select inner parameter" },
              },
              selection_modes = {
                ['@function.outer'] = 'V',
                ['@function.inner'] = 'V',
                ['@class.outer'] = 'V',
                ['@class.inner'] = 'V',
                ['@parameter.outer'] = 'v',
                ['@parameter.inner'] = 'v',
              },
            },
            
            move = {
              enable = true,
              set_jumps = true,
              goto_next_start = {
                ["]f"] = "@function.outer",
                ["]c"] = "@class.outer",
                ["]a"] = "@parameter.inner",
              },
              goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[c"] = "@class.outer",
                ["[a"] = "@parameter.inner",
              },
            },
          },
        }
      end,
    },
    {
      "kylechui/nvim-surround",
      event = "VeryLazy",
      config = function()
        require("nvim-surround").setup({})
      end
    }
    
  })

  -- Load VSCode-specific keymaps after plugins are initialized
  require('customKeymaps.vscode').setup()

end

return M
