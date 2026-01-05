return {
    -- DAP (Debug Adapter Protocol)
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            -- UI for DAP
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",

            -- Mason integration for auto-installing debuggers
            "jay-babu/mason-nvim-dap.nvim",

            -- Virtual text showing variable values
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- Setup mason-nvim-dap for auto-installing debuggers
            require("mason-nvim-dap").setup({
                ensure_installed = {
                    "python",      -- debugpy for Python
                    "codelldb",    -- for Rust, C, C++
                    "delve",       -- for Go
                    "js",          -- for JavaScript/TypeScript
                },
                automatic_installation = true,
                handlers = {},
            })

            -- Setup DAP UI
            dapui.setup({
                icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
                mappings = {
                    expand = { "<CR>", "<2-LeftMouse>" },
                    open = "o",
                    remove = "d",
                    edit = "e",
                    repl = "r",
                    toggle = "t",
                },
                layouts = {
                    {
                        elements = {
                            { id = "scopes", size = 0.25 },
                            { id = "breakpoints", size = 0.25 },
                            { id = "stacks", size = 0.25 },
                            { id = "watches", size = 0.25 },
                        },
                        size = 40,
                        position = "left",
                    },
                    {
                        elements = {
                            { id = "repl", size = 0.5 },
                            { id = "console", size = 0.5 },
                        },
                        size = 10,
                        position = "bottom",
                    },
                },
                floating = {
                    max_height = nil,
                    max_width = nil,
                    border = "rounded",
                    mappings = {
                        close = { "q", "<Esc>" },
                    },
                },
            })

            -- Setup virtual text (shows variable values inline)
            require("nvim-dap-virtual-text").setup({
                enabled = true,
                enabled_commands = true,
                highlight_changed_variables = true,
                highlight_new_as_changed = false,
                show_stop_reason = true,
                commented = false,
            })

            -- Automatically open/close DAP UI
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            -- Keybindings
            local map = vim.keymap.set

            -- Debug control
            map('n', '<leader>db', dap.toggle_breakpoint, { desc = 'Toggle breakpoint' })
            map('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { desc = 'Conditional breakpoint' })
            map('n', '<leader>dc', dap.continue, { desc = 'Continue/Start debugging' })
            map('n', '<leader>di', dap.step_into, { desc = 'Step into' })
            map('n', '<leader>do', dap.step_over, { desc = 'Step over' })
            map('n', '<leader>dO', dap.step_out, { desc = 'Step out' })
            map('n', '<leader>dr', dap.repl.open, { desc = 'Open REPL' })
            map('n', '<leader>dl', dap.run_last, { desc = 'Run last' })
            map('n', '<leader>dt', dap.terminate, { desc = 'Terminate' })

            -- DAP UI controls
            map('n', '<leader>du', dapui.toggle, { desc = 'Toggle DAP UI' })
            map('n', '<leader>de', dapui.eval, { desc = 'Evaluate expression' })

            -- Visual mode - evaluate selection
            map('v', '<leader>de', dapui.eval, { desc = 'Evaluate selection' })

            -- Signs for breakpoints
            vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointCondition', { text = '🟠', texthl = '', linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointRejected', { text = '🚫', texthl = '', linehl = '', numhl = '' })
            vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = 'debugPC', numhl = '' })
        end,
    },
}
