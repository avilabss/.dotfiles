return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "main",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
        },
        config = function()
           require("neo-tree").setup({
                filesystem = {
                    filtered_items = {
                        visible = true,
                        hide_dotfiles = false,
                        hide_gitignore = false,
                    },
                },
            })

            vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', {
                noremap = true,
                silent = true,
                desc = "Toggle Neo-tree",
            })
        end,
    },
}
