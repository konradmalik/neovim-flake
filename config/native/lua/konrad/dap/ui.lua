local dap = require("dap")
local dapui = require("dapui")

local icons = require("konrad.icons")

dapui.setup({
    icons = {
        expanded = icons.ui.Expanded,
        collapsed = icons.ui.Collapsed,
        current_frame = icons.ui.FoldClosed
    },
})

-- automatic open/close
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end
