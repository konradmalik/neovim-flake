local initialize_once = function()
    vim.cmd.packadd("nvim-dap")
    -- nio is a dependency of nvim-dap-ui
    vim.cmd.packadd("nvim-nio")
    vim.cmd.packadd("nvim-dap-ui")
    vim.cmd.packadd("nvim-dap-virtual-text")
end

local function load_configs()
    require("pde.dap.configs.cs")
    require("pde.dap.configs.go")
    require("pde.dap.configs.python")
end

local M = {}

function M.setup()
    initialize_once()

    require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
    })

    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()

    local map = function(lhs, rhs, desc)
        desc = "[DAP] " .. desc
        vim.keymap.set("n", lhs, rhs, { desc = desc })
    end

    map("<F1>", dap.continue, "continue")
    map("<F2>", dap.step_into, "step into")
    map("<F3>", dap.step_over, "step over")
    map("<F4>", dap.step_out, "step out")
    map("<F5>", dap.step_back, "step back")
    map("<F12>", dap.restart, "restart")
    map("<leader>db", dap.toggle_breakpoint, "toggle breakpoint")
    map("<leader>d?", function() dapui.eval(nil, { enter = true }) end, "evaluate under cursor")

    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

    load_configs()
end

return M
