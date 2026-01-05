return {
    {
        "tpope/vim-sleuth",
        -- No configuration needed! Just detects indentation automatically
        -- Works silently in the background
        event = { "BufReadPre", "BufNewFile" },
    },
}
