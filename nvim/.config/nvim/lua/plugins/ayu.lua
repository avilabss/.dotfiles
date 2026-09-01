-- Ayu provides Neovim's color scheme.
-- A high priority makes it load before plugins that derive colors from the theme.
return {
    {
        "Shatur/neovim-ayu",
        priority = 1000,
        config = function()
            require("ayu").setup({
                mirage = false,
                terminal = true,
            })
            vim.cmd.colorscheme("ayu-dark")
        end,
    },
}
