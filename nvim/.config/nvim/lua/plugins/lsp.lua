return {
    -- LSPconfig: Main LSP setup with all dependencies
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Mason: LSP server installer
            {
                "williamboman/mason.nvim",
                config = function()
                    require("mason").setup({
                        ui = {
                            icons = {
                                package_installed = "✓",
                                package_pending = "➜",
                                package_uninstalled = "✗"
                            }
                        }
                    })
                end,
            },

            -- Mason-lspconfig: Bridge between mason and lspconfig
            "williamboman/mason-lspconfig.nvim",

            -- Mason-tool-installer: Auto-install formatters and linters
            {
                "WhoIsSethDaniel/mason-tool-installer.nvim",
                config = function()
                    require("mason-tool-installer").setup({
                        ensure_installed = {
                            -- Formatters
                            "prettier",  -- JS/TS/HTML/CSS/JSON
                            "ruff",      -- Python formatter and linter
                        },
                        auto_update = false,
                        run_on_start = true,
                    })
                end,
            },

            -- LSP completion source
            "hrsh7th/cmp-nvim-lsp",
        },

        config = function()
            local lspconfig = require("lspconfig")

            -- LSP capabilities (advertise completion support)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- on_attach: Called when LSP attaches to a buffer
            local on_attach = function(client, bufnr)
                local opts = { buffer = bufnr, noremap = true, silent = true }

                -- LSP actions with <leader>l prefix
                vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
                vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
                vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'Show references' }))
                vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
                vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition, vim.tbl_extend('force', opts, { desc = 'Go to type definition' }))
                vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
                vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format({ async = false, timeout_ms = 2000 }) end, vim.tbl_extend('force', opts, { desc = 'Format buffer' }))
                vim.keymap.set('n', '<leader>lR', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
                vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
                vim.keymap.set('n', '<leader>ls', vim.lsp.buf.signature_help, vim.tbl_extend('force', opts, { desc = 'Signature help' }))
                vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = 'Show line diagnostics' }))
                vim.keymap.set('n', '<leader>ln', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
                vim.keymap.set('n', '<leader>lp', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
                vim.keymap.set('n', '<leader>lq', vim.diagnostic.setloclist, vim.tbl_extend('force', opts, { desc = 'Set diagnostics to quickfix' }))

                -- Classic vim keybindings (muscle memory)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
                vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
                vim.keymap.set('n', ']d', vim.diagnostic.goto_next, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))

                -- Format on save (only for languages not handled by conform.nvim)
                -- Conform handles: js, ts, jsx, tsx, json, html, css, scss, markdown, yaml, python
                local conform_filetypes = {
                    "javascript", "typescript", "javascriptreact", "typescriptreact",
                    "json", "html", "css", "scss", "markdown", "yaml", "python"
                }

                local filetype = vim.bo[bufnr].filetype
                local use_conform = vim.tbl_contains(conform_filetypes, filetype)

                if not use_conform then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
                        end,
                    })
                end
            end

            -- Diagnostic display configuration
            vim.diagnostic.config({
                virtual_text = true,
                signs = true,
                update_in_insert = false,
                underline = true,
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = "always",
                },
            })

            -- Setup mason-lspconfig with handlers
            require("mason-lspconfig").setup({
                -- Auto-install these LSP servers
                ensure_installed = {
                    "rust_analyzer",  -- Rust
                    "lua_ls",         -- Lua
                    "gopls",          -- Go
                    "pyright",        -- Python
                    "ts_ls",          -- TypeScript/JavaScript
                    "zls",            -- Zig
                    "html",           -- HTML
                    "cssls",          -- CSS
                    "ansiblels",      -- Ansible
                    "astro",          -- Astro
                    "svelte",         -- Svelte
                },
                automatic_installation = true,

                -- Handlers for automatic LSP setup
                handlers = {
                    -- Default handler for all servers
                    function(server_name)
                        lspconfig[server_name].setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                        })
                    end,

                    -- Special configuration for lua_ls (Neovim-aware)
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup({
                            on_attach = on_attach,
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    diagnostics = {
                                        globals = { 'vim' }, -- Recognize 'vim' global
                                    },
                                    workspace = {
                                        checkThirdParty = false,
                                    },
                                    telemetry = {
                                        enable = false,
                                    },
                                },
                            },
                        })
                    end,
                },
            })
        end,
    },
}
