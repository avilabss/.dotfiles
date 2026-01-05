return {
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("Comment").setup({
                -- Add a space between comment and the line
                padding = true,
                -- Ignore empty lines
                ignore = '^$',
                -- LHS of toggle mappings in NORMAL mode
                toggler = {
                    line = 'gcc',  -- Line-comment toggle
                    block = 'gbc', -- Block-comment toggle
                },
                -- LHS of operator-pending mappings in NORMAL and VISUAL mode
                opleader = {
                    line = 'gc',  -- Line-comment operator
                    block = 'gb', -- Block-comment operator
                },
                -- Enable keybindings
                mappings = {
                    basic = true,
                    extra = true,
                },
            })
        end,
    },
}
