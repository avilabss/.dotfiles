-- Telescope is a fuzzy-finder for quickly searching files and project content.
-- Use <leader>ff for files, <leader>fg for text, <leader>fb for open buffers,
-- and <leader>fh for Neovim help topics.
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
        end,
    },
}
