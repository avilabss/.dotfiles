-- indent-blankline (ibl) draws vertical guides that make nested code easier to read.
-- The active scope uses Catppuccin Mocha accents, recreated whenever the color
-- scheme changes so the guides keep their intended colors.
return {
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            local highlight = {
                "IblScopeRed",
                "IblScopeYellow",
                "IblScopeBlue",
                "IblScopePeach",
                "IblScopeGreen",
                "IblScopeMauve",
                "IblScopeTeal",
            }

            local hooks = require "ibl.hooks"
            -- create the highlight groups in the highlight setup hook, so they are reset
            -- every time the colorscheme changes
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "IblScopeRed", { fg = "#f38ba8" })
                vim.api.nvim_set_hl(0, "IblScopeYellow", { fg = "#f9e2af" })
                vim.api.nvim_set_hl(0, "IblScopeBlue", { fg = "#89b4fa" })
                vim.api.nvim_set_hl(0, "IblScopePeach", { fg = "#fab387" })
                vim.api.nvim_set_hl(0, "IblScopeGreen", { fg = "#a6e3a1" })
                vim.api.nvim_set_hl(0, "IblScopeMauve", { fg = "#cba6f7" })
                vim.api.nvim_set_hl(0, "IblScopeTeal", { fg = "#94e2d5" })
            end)

            require("ibl").setup({ scope = { highlight = highlight } })

            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
        end,
    },
}
