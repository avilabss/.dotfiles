-- Treesitter parses source code to improve highlighting and indentation.
-- Its textobjects let Vim motions understand functions, classes, parameters, blocks,
-- loops, and conditionals; it also adds structural navigation and swapping mappings.
return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        lazy = false,
        build = ':TSUpdate',
        dependencies = {
            {
                'nvim-treesitter/nvim-treesitter-textobjects',
                branch = 'main',
            },
        },
        config = function()
            local treesitter = require("nvim-treesitter")
            -- Prepend the managed parser/query directory even on a clean install,
            -- so parsers installed on demand can be loaded without restarting.
            local install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site")
            vim.fn.mkdir(install_dir, "p")
            treesitter.setup({
                install_dir = install_dir,
            })
            local available = {}
            local pending = {}

            for _, language in ipairs(treesitter.get_available()) do
                available[language] = true
            end

            local function has_query(language, query_group)
                local ok, query = pcall(vim.treesitter.query.get, language, query_group)
                return ok and query ~= nil
            end

            local function enable_features(buf, language)
                if not vim.api.nvim_buf_is_valid(buf) or not vim.treesitter.language.add(language) then
                    return false
                end

                if has_query(language, "highlights") then
                    vim.treesitter.start(buf, language)
                end
                if has_query(language, "indents") then
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
                return true
            end

            local function enable_when_installed(language, attempts)
                local buffers = pending[language]
                if not buffers then
                    return
                end

                if vim.treesitter.language.add(language) then
                    pending[language] = nil
                    for buf in pairs(buffers) do
                        if vim.api.nvim_buf_is_valid(buf) then
                            local filetype = vim.bo[buf].filetype
                            if filetype ~= "" and vim.treesitter.language.get_lang(filetype) == language then
                                enable_features(buf, language)
                            end
                        end
                    end
                elseif attempts < 1200 then
                    vim.defer_fn(function()
                        enable_when_installed(language, attempts + 1)
                    end, 100)
                else
                    pending[language] = nil
                end
            end

            local function enable_or_install(buf)
                local language = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
                if not language or enable_features(buf, language) then
                    return
                end
                if not available[language] or vim.fn.executable("tree-sitter") ~= 1 then
                    return
                end

                if pending[language] then
                    pending[language][buf] = true
                    return
                end

                pending[language] = { [buf] = true }
                treesitter.install(language)
                vim.defer_fn(function()
                    enable_when_installed(language, 1)
                end, 100)
            end

            -- The rewritten plugin has no auto_install option, so install missing
            -- supported parsers on demand and enable features after installation.
            local features_group = vim.api.nvim_create_augroup("TreesitterFeatures", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                group = features_group,
                callback = function(event)
                    enable_or_install(event.buf)
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                group = features_group,
                pattern = "MasonToolsUpdateCompleted",
                callback = function()
                    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        if vim.api.nvim_buf_is_loaded(buf) then
                            enable_or_install(buf)
                        end
                    end
                end,
            })

            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                },
                move = {
                    set_jumps = true,
                },
            })

            local select = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")
            local swap = require("nvim-treesitter-textobjects.swap")

            local selections = {
                af = "@function.outer",
                ["if"] = "@function.inner",
                ac = "@class.outer",
                ic = "@class.inner",
                aa = "@parameter.outer",
                ia = "@parameter.inner",
                ab = "@block.outer",
                ib = "@block.inner",
                al = "@loop.outer",
                il = "@loop.inner",
                ai = "@conditional.outer",
                ii = "@conditional.inner",
            }
            local function select_textobject(query)
                return function()
                    select.select_textobject(query, "textobjects")
                end
            end
            for key, query in pairs(selections) do
                vim.keymap.set({ "x", "o" }, key, select_textobject(query), {
                    desc = "Select " .. query:sub(2):gsub("%.", " "),
                })
            end

            local movements = {
                { "]f", move.goto_next_start, "@function.outer" },
                { "]c", move.goto_next_start, "@class.outer" },
                { "]a", move.goto_next_start, "@parameter.inner" },
                { "]F", move.goto_next_end, "@function.outer" },
                { "]C", move.goto_next_end, "@class.outer" },
                { "]A", move.goto_next_end, "@parameter.inner" },
                { "[f", move.goto_previous_start, "@function.outer" },
                { "[c", move.goto_previous_start, "@class.outer" },
                { "[a", move.goto_previous_start, "@parameter.inner" },
                { "[F", move.goto_previous_end, "@function.outer" },
                { "[C", move.goto_previous_end, "@class.outer" },
                { "[A", move.goto_previous_end, "@parameter.inner" },
            }
            local function move_to(move_function, query)
                return function()
                    move_function(query, "textobjects")
                end
            end
            for _, movement in ipairs(movements) do
                vim.keymap.set({ "n", "x", "o" }, movement[1], move_to(movement[2], movement[3]), {
                    desc = "Move to " .. movement[3]:sub(2):gsub("%.", " "),
                })
            end

            vim.keymap.set("n", "<leader>na", function()
                swap.swap_next("@parameter.inner")
            end, { desc = "Swap with next argument" })
            vim.keymap.set("n", "<leader>nf", function()
                swap.swap_next("@function.outer")
            end, { desc = "Swap with next function" })
            vim.keymap.set("n", "<leader>pa", function()
                swap.swap_previous("@parameter.inner")
            end, { desc = "Swap with previous argument" })
            vim.keymap.set("n", "<leader>pf", function()
                swap.swap_previous("@function.outer")
            end, { desc = "Swap with previous function" })
        end,
    },
}
