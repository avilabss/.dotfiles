return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
        require("copilot").setup({
            suggestion = {
                enabled = true,
                auto_trigger = true,
                keymap = {
                    accept = false, -- We handle Tab in cmp.lua
                    accept_word = "<M-w>",
                    accept_line = "<M-l>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
            },
            panel = {
                enabled = true,
                keymap = {
                    open = "<M-CR>",
                },
            },
            filetypes = {
                markdown = true,
                help = false,
                gitcommit = true,
                gitrebase = false,
                ["."] = false,
            },
        })
    end,
}
