return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")

            wk.setup({
                preset = "modern",
                delay = 500, -- delay before showing which-key popup
                icons = {
                    mappings = true,
                },
                win = {
                    border = "rounded",
                },
            })

            -- Register prefixes to give them names
            wk.add({
                { "<leader>f", group = "Find (Telescope)" },
                { "<leader>l", group = "LSP" },
                { "<leader>g", group = "Git" },
                { "<leader>t", group = "Terminal" },
                { "<leader>s", group = "Session" },
                { "<leader>d", group = "Debug (DAP)" },
                { "<leader>n", group = "Next (Swap)" },
                { "<leader>p", group = "Previous (Swap)" },
            })
        end,
    },
}
