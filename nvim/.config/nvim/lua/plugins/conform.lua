-- conform.nvim formats source files with external tools such as Prettier and Ruff.
-- It formats supported files before saving and falls back to the attached LSP when
-- no configured formatter is available. :Format also formats manually.
return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo", "Format" },
        config = function()
            local prettier = require("conform.formatters.prettier")

            local function local_svelte_prettier(ctx)
                local dir = ctx.dirname
                local executable = vim.fn.has("win32") == 1 and "prettier.cmd" or "prettier"

                while dir do
                    local prettier_path = vim.fs.joinpath(dir, "node_modules", ".bin", executable)
                    local plugin_path = vim.fs.joinpath(dir, "node_modules", "prettier-plugin-svelte", "package.json")
                    if vim.fn.executable(prettier_path) == 1 and vim.uv.fs_stat(plugin_path) then
                        return {
                            command = prettier_path,
                            cwd = dir,
                        }
                    end

                    local parent = vim.fs.dirname(dir)
                    if not parent or parent == dir then
                        break
                    end
                    dir = parent
                end
            end

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
                    python = { "ruff_organize_imports", "ruff_format" },
                    rust = { "rustfmt" },
                    go = { "goimports" },
                    svelte = { "prettier" },
                },

                default_format_opts = {
                    lsp_format = "fallback",
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
                        command = function(self, ctx)
                            local integration = vim.bo[ctx.buf].filetype == "svelte" and local_svelte_prettier(ctx)
                            return integration and integration.command or prettier.command(self, ctx)
                        end,
                        condition = function(_, ctx)
                            return vim.bo[ctx.buf].filetype ~= "svelte" or local_svelte_prettier(ctx) ~= nil
                        end,
                        cwd = function(self, ctx)
                            local integration = vim.bo[ctx.buf].filetype == "svelte" and local_svelte_prettier(ctx)
                            return integration and integration.cwd or prettier.cwd(self, ctx)
                        end,
                        prepend_args = function(_, ctx)
                            local args = {
                                "--single-quote",
                                "--trailing-comma", "es5",
                            }
                            if vim.bo[ctx.buf].filetype == "svelte" then
                                vim.list_extend(args, { "--plugin", "prettier-plugin-svelte", "--parser", "svelte" })
                            end
                            return args
                        end,
                    },
                },
            })

            -- Format the current buffer or command range through Conform.
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
