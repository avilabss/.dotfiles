return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        config = function()
            require("conform").setup({
                -- Define formatters by filetype
                formatters_by_ft = {
                    javascript = { "prettier" },
                    typescript = { "prettier" },
                    javascriptreact = { "prettier" },
                    typescriptreact = { "prettier" },
                    json = { "prettier" },
                    html = { "prettier" },
                    css = { "prettier" },
                    scss = { "prettier" },
                    markdown = { "prettier" },
                    yaml = { "prettier" },
                    python = { "ruff_format", "ruff_organize_imports" },
                },

                -- Format on save
                format_on_save = {
                    -- These options will be passed to conform.format()
                    timeout_ms = 2000,
                    lsp_format = "fallback", -- Use LSP if conform formatter not available
                },

                -- Customize formatters
                formatters = {
                    prettier = {
                        prepend_args = {
                            "--single-quote",
                            "--trailing-comma", "es5",
                        },
                    },
                },
            })

            -- Optional: Add command to format current buffer manually
            vim.api.nvim_create_user_command("Format", function(args)
                local range = nil
                if args.count ~= -1 then
                    local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
                    range = {
                        start = { args.line1, 0 },
                        ["end"] = { args.line2, end_line:len() },
                    }
                end
                require("conform").format({ async = true, lsp_format = "fallback", range = range })
            end, { range = true })
        end,
    },
}
