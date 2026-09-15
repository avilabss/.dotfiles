-- Fugitive provides repository-wide status, staging, and native Vim diff splits.
-- Use <leader>gg to open status; Fugitive's built-in status mappings stay unchanged.
return {
    {
        "tpope/vim-fugitive",
        -- Register fugitive:// buffer handlers before auto-session restores windows.
        lazy = false,
        keys = {
            { "<leader>gg", "<cmd>Git<cr>", desc = "Git status (Fugitive)" },
        },
    },
}
