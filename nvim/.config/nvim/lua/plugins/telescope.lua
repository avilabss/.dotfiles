-- Telescope is a fuzzy-finder for quickly searching files, project content, and keymaps.
-- Use <leader>ff for files, <leader>fg for text, <leader>fb for open buffers,
-- <leader>fh for Neovim help topics, and <leader>ch for the keymap cheatsheet.
return {
    {
        'nvim-telescope/telescope.nvim', 
        dependencies = {
            'nvim-lua/plenary.nvim' 
        },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
            vim.keymap.set('n', '<leader>ch', function()
                builtin.keymaps({
                    modes = { 'n', 'i', 'x', 'o', 't' },
                    show_plug = false,
                    filter = function(keymap)
                        return keymap.desc ~= nil and keymap.desc ~= ''
                    end,
                })
            end, { desc = 'Search keymap cheatsheet' })
        end,
    },
}
