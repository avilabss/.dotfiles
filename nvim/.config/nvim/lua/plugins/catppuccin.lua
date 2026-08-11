-- Catppuccin provides Neovim's color scheme.
-- A high priority makes it load before plugins that derive colors from the theme.
-- This configuration uses the dark "Mocha" flavour shared by the other dotfiles.
return {
    {
        "catppuccin/nvim", 
        name = "catppuccin", 
        priority = 1000,
        config = function()
             require("catppuccin").setup({
                flavour = "mocha",
                transparent_background = false,
             })
             vim.cmd.colorscheme("catppuccin-nvim")
        end,
    },
}
