-- Fugitive provides repository-wide status, staging, and native Vim diff splits.
-- Use <leader>gg to open status; Fugitive's built-in status mappings stay unchanged.
return {
    {
        "tpope/vim-fugitive",
        cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Ghdiffsplit" },
        keys = {
            { "<leader>gg", "<cmd>Git<cr>", desc = "Git status (Fugitive)" },
        },
    },
}
