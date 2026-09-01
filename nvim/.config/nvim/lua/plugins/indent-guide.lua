-- indent-blankline (ibl) draws vertical guides that make nested code easier to read.
-- The active scope uses Ayu Dark accents, recreated whenever the color
-- scheme changes so the guides keep their intended colors.
return {
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            local highlight = {
                "IblScopeCoral",
                "IblScopeGold",
                "IblScopeBlue",
                "IblScopeOrange",
                "IblScopeGreen",
                "IblScopePurple",
                "IblScopeCyan",
            }

            local hooks = require "ibl.hooks"
            -- create the highlight groups in the highlight setup hook, so they are reset
            -- every time the colorscheme changes
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "IblScopeCoral", { fg = "#F07178" })
                vim.api.nvim_set_hl(0, "IblScopeGold", { fg = "#FFB454" })
                vim.api.nvim_set_hl(0, "IblScopeBlue", { fg = "#59C2FF" })
                vim.api.nvim_set_hl(0, "IblScopeOrange", { fg = "#FF8F40" })
                vim.api.nvim_set_hl(0, "IblScopeGreen", { fg = "#AAD94C" })
                vim.api.nvim_set_hl(0, "IblScopePurple", { fg = "#D2A6FF" })
                vim.api.nvim_set_hl(0, "IblScopeCyan", { fg = "#95E6CB" })
            end)

            require("ibl").setup({ scope = { highlight = highlight } })

            hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
        end,
    },
}
