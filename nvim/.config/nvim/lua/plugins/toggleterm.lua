-- toggleterm manages terminal windows inside Neovim.
-- Ctrl+\ toggles the default floating terminal; <leader>tf/th/tv opens a floating,
-- horizontal, or vertical terminal. Escape returns from terminal mode to Normal mode.
return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                open_mapping = [[<C-\>]], -- Ctrl+\ to toggle terminal
                hide_numbers = true,
                shade_terminals = true,
                shading_factor = 2,
                start_in_insert = true,
                insert_mappings = true,
                terminal_mappings = true,
                persist_size = true,
                persist_mode = true,
                direction = 'float', -- 'vertical' | 'horizontal' | 'tab' | 'float'
                close_on_exit = true,
                shell = vim.o.shell,
                auto_scroll = true,
                float_opts = {
                    border = 'curved', -- 'single' | 'double' | 'shadow' | 'curved'
                    winblend = 0,
                },
            })

            -- Custom keybindings
            local map = vim.keymap.set
            map('n', '<leader>tf', ':ToggleTerm direction=float<CR>', { desc = 'Floating terminal', noremap = true, silent = true })
            map('n', '<leader>th', ':ToggleTerm direction=horizontal<CR>', { desc = 'Horizontal terminal', noremap = true, silent = true })
            map('n', '<leader>tv', ':ToggleTerm direction=vertical<CR>', { desc = 'Vertical terminal', noremap = true, silent = true })

            -- Terminal mode mappings, scoped only to Toggleterm buffers.
            local terminal_group = vim.api.nvim_create_augroup("ToggletermMappings", { clear = true })
            vim.api.nvim_create_autocmd("TermOpen", {
                group = terminal_group,
                pattern = "term://*toggleterm#*",
                callback = function(event)
                    local opts = { buffer = event.buf }
                    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts) -- ESC to exit terminal mode
                    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
                    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
                    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
                    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
                end,
            })
        end,
    },
}
