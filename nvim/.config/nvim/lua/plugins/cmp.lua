return {
    -- LuaSnip: Snippet engine
    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
    },

    -- nvim-cmp: Completion engine
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",    -- LSP completion source
            "hrsh7th/cmp-buffer",      -- Buffer text completion
            "hrsh7th/cmp-path",        -- File path completion
            "L3MON4D3/LuaSnip",        -- Snippet engine
            "saadparwaiz1/cmp_luasnip", -- Snippet completion source
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },

                mapping = cmp.mapping.preset.insert({
                    -- Trigger completion manually
                    ['<C-Space>'] = cmp.mapping.complete(),

                    -- Navigate completion menu (vim defaults)
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),

                    -- Scroll documentation window
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),

                    -- Confirm completion
                    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Don't auto-select

                    -- Tab/Shift-Tab: Accept Copilot, navigate cmp, or expand snippet
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        local copilot = require("copilot.suggestion")
                        if copilot.is_visible() then
                            copilot.accept()
                        elseif cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),

                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),

                -- Completion sources (order = priority)
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },  -- LSP completions (highest priority)
                    { name = 'luasnip' },   -- Snippet completions
                    { name = 'path' },      -- File path completions
                }, {
                    { name = 'buffer' },    -- Buffer text (lower priority)
                }),

                -- Completion menu appearance
                formatting = {
                    format = function(entry, vim_item)
                        -- Source names
                        vim_item.menu = ({
                            nvim_lsp = '[LSP]',
                            luasnip = '[Snippet]',
                            buffer = '[Buffer]',
                            path = '[Path]',
                        })[entry.source.name]
                        return vim_item
                    end,
                },

                -- Completion behavior
                completion = {
                    completeopt = 'menu,menuone,noinsert,noselect',
                },

                -- Experimental features
                experimental = {
                    ghost_text = false, -- Don't show ghost text
                },
            })
        end,
    },
}
