local setup = function()
    require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
    })

    local dap = require("dap")
    local dapui = require("dapui")

    local icons = require("pde.icons")

    dapui.setup({
        icons = {
            expanded = icons.ui.Expanded,
            collapsed = icons.ui.Collapsed,
            current_frame = icons.ui.FoldClosed,
        },
    })

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
end

local initialized = false
local initialize_once = function()
    if initialized then return end

    vim.cmd.packadd("nvim-dap")
    -- nio is a dependency of nvim-dap-ui
    vim.cmd.packadd("nvim-nio")
    vim.cmd.packadd("nvim-dap-ui")
    vim.cmd.packadd("nvim-dap-virtual-text")

    setup()

    initialized = true
end

local M = {}

--- Configure DAP by name
---
---Built-in names
---      - cs
---      - go
---      - python
--- If anything else, a whole configuration function needs to be provided.
---
---@param dap string|function - dap config name or a function that configures it
---@return nil
M.init = function(dap)
    initialize_once()

    if type(dap) == "string" then
        local found, _ = pcall(require, "pde.dap.configs." .. dap)
        if not found then vim.notify("could not find DAP config for " .. dap) end
    elseif type(dap) == "function" then
        dap()
    else
        vim.notify("bad type for dap config: " .. vim.inspect(dap), vim.log.levels.ERROR)
    end
end

return M
