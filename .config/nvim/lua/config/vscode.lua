-- filepath: /home/fedusr/.config/nvim/lua/config/vscode.lua
-- VSCode Neovim configuration
local M = {}

M.setup = function()
  -- Basic options that work well in VSCode
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.scrolloff = 15
  vim.opt.clipboard = 'unnamedplus'
  -- Make leader key timeout shorter to improve responsiveness when working with VSpaceCode
  vim.opt.timeoutlen = 200
  
  -- Set leader key for Neovim - this will be used when space is passed to Neovim
  vim.g.mapleader = ' '
  
  -- Handle VSpaceCode integration better
  -- This helps ensure that space works correctly with both Neovim and VSpaceCode
  vim.g.vscode_space_handled_by_vspacecode = true
  
  -- Register custom Neovim commands that can be called from VSpaceCode menu
  M.register_vscode_commands()
end

-- Function to register custom commands that can be called from VSpaceCode
M.register_vscode_commands = function()
  -- Example of registering a custom Neovim command that can be called from VSpaceCode
  vim.api.nvim_create_user_command("VSCodeCustomCommand", function(opts)
    -- This will execute a VSCode command
    local cmd = opts.args or "workbench.action.showCommands"
    vim.fn.VSCodeNotify(cmd)
  end, {nargs = "?"})
  
  -- Custom Treesitter commands for VSpaceCode integration
  vim.api.nvim_create_user_command("TSVisualSelection", function()
    vim.cmd("normal! v")
    require("nvim-treesitter.incremental_selection").init_selection()
  end, {})
  
  vim.api.nvim_create_user_command("TSIncremental", function()
    require("nvim-treesitter.incremental_selection").node_incremental()
  end, {})
  
  vim.api.nvim_create_user_command("TSDecremental", function()
    require("nvim-treesitter.incremental_selection").node_decremental()
  end, {})
  
  -- VSCode integration commands
  vim.api.nvim_create_user_command("VSQuickOpen", function()
    vim.fn.VSCodeNotify("workbench.action.quickOpen")
  end, {})
  
  vim.api.nvim_create_user_command("VSFindInFiles", function()
    vim.fn.VSCodeNotify("workbench.action.findInFiles")
  end, {})
  
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
    },        -- Mini.nvim modules that work well in VSCode
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
        -- Move text with custom mappings to avoid conflicts
        require('mini.move').setup({
          mappings = {
            -- Move visual selection in Visual mode with Alt+Shift instead of Alt
            left = '<A-S-h>',
            right = '<A-S-l>',
            down = '<A-S-j>',
            up = '<A-S-k>',
            -- Move current line in Normal mode with Alt+Shift
            line_left = '<A-S-h>',
            line_right = '<A-S-l>',
            line_down = '<A-S-j>',
            line_up = '<A-S-k>',
          },
        })
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
