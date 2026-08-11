-- This file configures Neovim's Language Server Protocol (LSP) support.
-- Mason installs language servers and developer tools; lspconfig connects them to
-- buffers for navigation, diagnostics, renaming, code actions, and completion.
-- Most language actions use <leader>l; familiar mappings such as gd and K also work.
return {
    -- LSPconfig: Main LSP setup with all dependencies
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            -- Mason: LSP server installer
            {
                "mason-org/mason.nvim",
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

            -- Mason-lspconfig: installs and enables the configured servers
            "mason-org/mason-lspconfig.nvim",

            -- Mason-tool-installer: Auto-install formatters and linters
            {
                "WhoIsSethDaniel/mason-tool-installer.nvim",
                dependencies = { "mason-org/mason.nvim" },
                config = function()
                    require("mason-tool-installer").setup({
                        ensure_installed = {
                            -- Formatters
                            "prettier",  -- JS/TS/HTML/CSS/JSON
                            "ruff",      -- Python formatter and linter
                            "goimports", -- Go formatter and import organizer
                            "tree-sitter-cli", -- Parser compiler required by nvim-treesitter
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
            -- LSP capabilities (advertise completion support)
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- on_attach: Called when LSP attaches to a buffer
            local on_attach = function(_, bufnr)
                local opts = { buffer = bufnr, noremap = true, silent = true }

                -- LSP actions with <leader>l prefix
                vim.keymap.set('n', '<leader>ld', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
                vim.keymap.set('n', '<leader>lD', vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Go to declaration' }))
                vim.keymap.set('n', '<leader>lr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'Show references' }))
                vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Go to implementation' }))
                vim.keymap.set('n', '<leader>lt', vim.lsp.buf.type_definition, vim.tbl_extend('force', opts, { desc = 'Go to type definition' }))
                vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, vim.tbl_extend('force', opts, { desc = 'Code action' }))
                vim.keymap.set('n', '<leader>lf', '<cmd>Format<CR>', vim.tbl_extend('force', opts, { desc = 'Format buffer' }))
                vim.keymap.set('n', '<leader>lR', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'Rename symbol' }))
                vim.keymap.set('n', '<leader>lh', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
                vim.keymap.set('n', '<leader>ls', vim.lsp.buf.signature_help, vim.tbl_extend('force', opts, { desc = 'Signature help' }))
                vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, vim.tbl_extend('force', opts, { desc = 'Show line diagnostics' }))
                vim.keymap.set('n', '<leader>ln', function() vim.diagnostic.jump({ count = 1 }) end, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
                vim.keymap.set('n', '<leader>lp', function() vim.diagnostic.jump({ count = -1 }) end, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
                vim.keymap.set('n', '<leader>lq', vim.diagnostic.setloclist, vim.tbl_extend('force', opts, { desc = 'Set diagnostics to location list' }))

                -- Classic vim keybindings (muscle memory)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Go to definition' }))
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
                vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
                vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
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

            local servers = {
                "rust_analyzer",  -- Rust
                "lua_ls",         -- Lua
                "gopls",          -- Go
                "pyright",        -- Python
                "ruff",           -- Python linting and code actions
                "ts_ls",          -- TypeScript/JavaScript
                "zls",            -- Zig
                "html",           -- HTML
                "cssls",          -- CSS
                "ansiblels",      -- Ansible
                "svelte",         -- Svelte
                "eslint",         -- JavaScript/TypeScript linting
                "jsonls",         -- JSON/JSONC
            }

            -- Shared settings are merged with the server definitions from nvim-lspconfig.
            vim.lsp.config("*", {
                on_attach = on_attach,
                capabilities = capabilities,
            })

            -- Keep lua_ls aware that this configuration runs inside Neovim.
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { 'vim' },
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = { vim.env.VIMRUNTIME },
                        },
                        telemetry = {
                            enable = false,
                        },
                    },
                },
            })

            vim.lsp.config("rust_analyzer", {
                settings = {
                    ["rust-analyzer"] = {
                        check = {
                            command = "clippy",
                        },
                    },
                },
            })

            vim.lsp.config("gopls", {
                settings = {
                    gopls = {
                        staticcheck = true,
                    },
                },
            })

            -- Pyright remains the Python hover/type provider while Ruff supplies
            -- diagnostics and code actions. Compose with the shared attachment setup.
            vim.lsp.config("ruff", {
                on_attach = function(client, bufnr)
                    client.server_capabilities.hoverProvider = false
                    on_attach(client, bufnr)
                end,
            })

            -- nvim-lspconfig's ESLint root resolver already requires a real ESLint
            -- configuration. Keep its commands, but leave all formatting to Conform.
            local eslint_on_attach = vim.lsp.config.eslint.on_attach
            vim.lsp.config("eslint", {
                filetypes = {
                    "javascript",
                    "javascriptreact",
                    "typescript",
                    "typescriptreact",
                    "svelte",
                },
                settings = {
                    format = false,
                },
                on_attach = function(client, bufnr)
                    client.server_capabilities.documentFormattingProvider = false
                    client.server_capabilities.documentRangeFormattingProvider = false
                    if eslint_on_attach then
                        eslint_on_attach(client, bufnr)
                    end
                    on_attach(client, bufnr)
                end,
            })

            -- Mason v2 installs this exact set and enables each server once through vim.lsp.enable().
            require("mason-lspconfig").setup({
                ensure_installed = servers,
                automatic_enable = servers,
            })
        end,
    },
}
