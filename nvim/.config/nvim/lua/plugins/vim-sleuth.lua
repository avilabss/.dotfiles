-- vim-sleuth detects whether each file uses tabs or spaces and chooses the matching
-- indentation width automatically. It works in the background with no keybindings.
return {
    {
        "tpope/vim-sleuth",
        -- No configuration needed! Just detects indentation automatically
        -- Works silently in the background
        event = { "BufReadPre", "BufNewFile" },
    },
}
