-- lualine replaces Neovim's status line with useful editor and project information.
-- It shows the current mode, Git branch/diff, diagnostics, file path/type, progress,
-- and cursor location in one global Ayu-themed status line.
return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "ayu", -- Use the integration supplied by neovim-ayu
                    component_separators = { left = '|', right = '|' },
                    section_separators = { left = '', right = '' },
                    globalstatus = true, -- Single statusline for all windows
                    disabled_filetypes = {
                        statusline = { "neo-tree" },
                    },
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = {
                        'branch',
                        'diff',
                        {
                            'diagnostics',
                            sources = { 'nvim_lsp' },
                            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
                        }
                    },
                    lualine_c = {
                        {
                            'filename',
                            path = 1, -- 0: Just filename, 1: Relative path, 2: Absolute path
                            symbols = {
                                modified = ' ●',
                                readonly = ' ',
                                unnamed = '[No Name]',
                            }
                        }
                    },
                    lualine_x = { 'encoding', 'fileformat', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {}
                },
                extensions = { 'neo-tree', 'lazy', 'mason' }
            })
        end,
    },
}
