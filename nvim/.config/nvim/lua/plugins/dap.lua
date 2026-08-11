-- nvim-dap adds debugger support using the Debug Adapter Protocol.
-- Its companion plugins install adapters, provide debugger panels, and show variable
-- values inline. Debug commands use the <leader>d prefix.
return {
    -- DAP (Debug Adapter Protocol)
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "mason-org/mason.nvim",

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
            local mason_dap = require("mason-nvim-dap")

            local function environment_python(prefix)
                if not prefix or prefix == "" then
                    return nil
                end

                local path = vim.fn.has("win32") == 1
                    and vim.fs.joinpath(prefix, "Scripts", "python.exe")
                    or vim.fs.joinpath(prefix, "bin", "python")
                return vim.fn.executable(path) == 1 and path or nil
            end

            local function resolve_python()
                local active_python = environment_python(vim.env.VIRTUAL_ENV)
                    or environment_python(vim.env.CONDA_PREFIX)
                if active_python then
                    return active_python
                end

                local filename = vim.api.nvim_buf_get_name(0)
                local project_root = vim.fs.root(filename ~= "" and filename or 0, {
                    "pyproject.toml",
                    "setup.py",
                    "setup.cfg",
                    "requirements.txt",
                    ".git",
                }) or vim.fn.getcwd()
                for _, directory in ipairs({ ".venv", "venv" }) do
                    local project_python = environment_python(vim.fs.joinpath(project_root, directory))
                    if project_python then
                        return project_python
                    end
                end

                for _, executable in ipairs({ "python3", "python" }) do
                    local system_python = vim.fn.exepath(executable)
                    if system_python ~= "" then
                        return system_python
                    end
                end

                vim.notify("No Python interpreter is available for debugpy", vim.log.levels.ERROR)
                return dap.ABORT
            end

            -- Setup mason-nvim-dap for auto-installing debuggers
            mason_dap.setup({
                ensure_installed = {
                    "python",      -- debugpy for Python
                    "codelldb",    -- for Rust, C, C++
                    "delve",       -- for Go
                    "js",          -- for JavaScript/TypeScript
                },
                automatic_installation = true,
                handlers = {
                    function(config)
                        mason_dap.default_setup(config)
                    end,
                    python = function(config)
                        for _, configuration in ipairs(config.configurations or {}) do
                            configuration.pythonPath = resolve_python
                        end
                        mason_dap.default_setup(config)
                    end,
                },
            })

            local function js_debug_adapter(translated_type)
                return function(callback)
                    local command = vim.fn.exepath("js-debug-adapter")
                    if command == "" then
                        vim.notify(
                            "Mason's js-debug-adapter is unavailable; install it with :DapInstall js",
                            vim.log.levels.ERROR
                        )
                        return
                    end

                    local adapter = {
                        type = "server",
                        host = "127.0.0.1",
                        port = "${port}",
                        executable = {
                            command = command,
                            args = { "${port}", "127.0.0.1" },
                        },
                    }
                    if translated_type then
                        adapter.enrich_config = function(config, on_config)
                            local translated = vim.deepcopy(config)
                            translated.type = translated_type
                            on_config(translated)
                        end
                    end
                    callback(adapter)
                end
            end

            -- vscode-js-debug's standalone server uses the pwa-* types. The
            -- aliases keep common VS Code launch.json types usable without
            -- mutating the project configurations that nvim-dap loads on demand.
            dap.adapters["pwa-node"] = js_debug_adapter()
            dap.adapters["pwa-chrome"] = js_debug_adapter()
            dap.adapters.node = js_debug_adapter("pwa-node")
            dap.adapters.chrome = js_debug_adapter("pwa-chrome")

            local javascript_configurations = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Node: Launch current file",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                    console = "integratedTerminal",
                },
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Node: Attach to process",
                    processId = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                },
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Chrome: Launch URL",
                    url = function()
                        return vim.fn.input("URL: ", "http://localhost:3000")
                    end,
                    webRoot = "${workspaceFolder}",
                    sourceMaps = true,
                },
                {
                    type = "pwa-chrome",
                    request = "attach",
                    name = "Chrome: Attach to debug port",
                    port = function()
                        return tonumber(vim.fn.input("Chrome debug port: ", "9222")) or 9222
                    end,
                    webRoot = "${workspaceFolder}",
                    sourceMaps = true,
                },
            }
            for _, filetype in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
                dap.configurations[filetype] = vim.deepcopy(javascript_configurations)
            end

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
