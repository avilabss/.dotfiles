return {
    {
        "rmagatti/auto-session",
        config = function()
            require("auto-session").setup({
                log_level = "error",
                auto_session_enabled = true,
                auto_save_enabled = true,
                auto_restore_enabled = true,
                auto_session_suppress_dirs = {
                    "~/",
                    "~/Downloads",
                    "~/Documents",
                    "/tmp",
                },
                auto_session_use_git_branch = false,
                bypass_session_save_file_types = {
                    "neo-tree",
                },

                -- Session lens (telescope integration)
                session_lens = {
                    load_on_setup = true,
                    theme_conf = { border = true },
                    previewer = false,
                },
            })

            -- Keybindings
            local map = vim.keymap.set
            map('n', '<leader>ss', ':SessionSave<CR>', { desc = 'Save session', noremap = true, silent = true })
            map('n', '<leader>sr', ':SessionRestore<CR>', { desc = 'Restore session', noremap = true, silent = true })
            map('n', '<leader>sd', ':SessionDelete<CR>', { desc = 'Delete session', noremap = true, silent = true })
            map('n', '<leader>sf', ':SessionSearch<CR>', { desc = 'Find sessions', noremap = true, silent = true })
        end,
    },
}
