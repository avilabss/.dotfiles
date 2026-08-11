-- auto-session remembers the files and window layout for each project.
-- It saves automatically when leaving and restores automatically when returning.
-- Use <leader>s followed by s/r/d/f to save, restore, delete, or find sessions.
return {
    {
        "rmagatti/auto-session",
        config = function()
            -- Preserve local buffer options so restored sessions retain filetypes and highlighting.
            vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

            require("auto-session").setup({
                log_level = "error",
                enabled = true,
                auto_save = true,
                auto_restore = true,
                legacy_cmds = false,
                suppressed_dirs = {
                    "~/",
                    "~/Downloads",
                    "~/Documents",
                    "/tmp",
                },
                git_use_branch_name = false,
                bypass_save_filetypes = {
                    "neo-tree",
                },

                -- Session lens (telescope integration)
                session_lens = {
                    load_on_setup = true,
                    picker_opts = {
                        border = true,
                        previewer = false,
                    },
                },
            })

            -- Keybindings
            local map = vim.keymap.set
            map('n', '<leader>ss', '<cmd>AutoSession save<CR>', { desc = 'Save session', noremap = true, silent = true })
            map('n', '<leader>sr', '<cmd>AutoSession restore<CR>', { desc = 'Restore session', noremap = true, silent = true })
            map('n', '<leader>sd', '<cmd>AutoSession delete<CR>', { desc = 'Delete session', noremap = true, silent = true })
            map('n', '<leader>sf', '<cmd>AutoSession search<CR>', { desc = 'Find sessions', noremap = true, silent = true })
        end,
    },
}
