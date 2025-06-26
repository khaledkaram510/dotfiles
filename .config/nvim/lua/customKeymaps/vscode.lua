-- VSCode-specific keymaps
local M = {}

M.setup = function()
    local utils = require('customKeymaps.utils')
    local map = utils.map
    -- stay in indent mode
    map('v', '<', '<gv')
    map('v', '>', '>gv')
    -- basic vscode integration
    map('n', '<esc>', utils.clear_highlights)
    map('t', '<esc><esc>', '<c-\\><c-n>', { desc = 'exit terminal mode' })
    map('n', '<leader>p', function() utils.vscode_notify('workbench.action.showcommands') end)
    map('n', '<leader>e', function() utils.vscode_notify('workbench.action.togglesidebarvisibility') end)
    map('n', '<leader>f', function() utils.vscode_notify('workbench.action.quickopen') end)
    map('n', '<leader>sg', function() utils.vscode_notify('workbench.action.findinfiles') end)

    -- Multiple Cursors (multicursor.nvim)
    local ok_mc, mc = pcall(require, "multicursor-nvim")
    if ok_mc then
        -- Add cursor above/below current line
        map({"n", "x"}, "<c-up>", function() mc.lineAddCursor(-1) end)
        map({"n", "x"}, "<C-Down>", function() mc.lineAddCursor(1) end)
        -- Add cursor at next match of word
        map({"n", "x"}, "<C-n>", function() mc.matchAddCursor(1) end)
        -- Toggle cursor mode
        map({"n", "x"}, "<C-q>", mc.toggleCursor)

        -- Multiple Cursors Navigation Layer
        mc.addKeymapLayer(function(layerSet)
            -- Navigate between cursors
            layerSet({"n", "x"}, "<left>", mc.prevCursor)
            layerSet({"n", "x"}, "<right>", mc.nextCursor)
            -- Enable/disable cursors with Escape
            layerSet("n", "<esc>", function()
                if not mc.cursorsEnabled() then
                    mc.enableCursors()
                else
                    mc.clearCursors()
                end
            end)
        end)
    end

    -- Enhanced increment/decrement (dial.nvim)
    local ok_dial = pcall(require, "dial.map")
    if ok_dial then
        -- Increment number under cursor
        map("n", "<C-a>", function() 
            return require("dial.map").inc_normal() 
        end, { expr = true })
        -- Decrement number under cursor
        map("n", "<C-x>", function() 
            return require("dial.map").dec_normal() 
        end, { expr = true })
    end

    -- Treesitter Selection
    local ok_ts = pcall(require, "nvim-treesitter")
    if ok_ts then
        -- Start visual selection with treesitter
        map("n", "<leader>v", function()
            vim.cmd("normal! v")
            require("nvim-treesitter.incremental_selection").init_selection()
        end)
        -- Increment/decrement selection
        map("x", "<leader>]", function()
            require("nvim-treesitter.incremental_selection").node_incremental()
        end)
        map("x", "<leader>[", function()
            require("nvim-treesitter.incremental_selection").node_decremental()
        end)
        -- Increment selection to scope
        map("x", "<leader>s", function()
            require("nvim-treesitter.incremental_selection").scope_incremental()
        end)

        -- Treesitter Movement
        -- Next/previous function
        map("n", "]f", function()
            require("nvim-treesitter.textobjects.move").goto_next_start("@function.outer")
        end)
        map("n", "[f", function()
            require("nvim-treesitter.textobjects.move").goto_previous_start("@function.outer")
        end)
        -- Next/previous class
        map("n", "]c", function()
            require("nvim-treesitter.textobjects.move").goto_next_start("@class.outer")
        end)
        map("n", "[c", function()
            require("nvim-treesitter.textobjects.move").goto_previous_start("@class.outer")
        end)
        -- Next/previous parameter
        map("n", "]a", function()
            require("nvim-treesitter.textobjects.move").goto_next_start("@parameter.inner")
        end)
        map("n", "[a", function()
            require("nvim-treesitter.textobjects.move").goto_previous_start("@parameter.inner")
        end)
    end

--[[     local ok_flash = pcall(require, "flash")
    if ok_flash then
        -- Flash integration
        map({ "n", "x", "o" },"s", function() require("flash").jump() end, {desc = "Flash"} )
        map({ "n", "x", "o" }, "S", function() require("flash").treesitter() end,{ desc = "Flash Treesitter"} )
        map("o", "r",function() require("flash").remote() end, {desc = "Remote Flash" })
        map({ "o", "x" }, "R",function() require("flash").treesitter_search() end, {desc = "Treesitter Search"} )
        map({ "c" }, "<c-s>",function() require("flash").toggle() end, {desc = "Toggle Flash Search"} )
    end ]]
end

return M