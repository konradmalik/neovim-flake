local dap = require("dap")
local dapui = require("dapui")

local map = function(lhs, rhs, desc)
    desc = "[DAP] " .. desc
    vim.keymap.set("n", lhs, rhs, { desc = desc })
end

map("<leader>dc", dap.continue, "continue")
map("<leader>dsv", dap.step_over, "step over")
map("<leader>dsi", dap.step_into, "step into")
map("<leader>dso", dap.step_out, "step out")
map("<leader>dr", dap.repl.open, "repl")
map("<leader>db", dap.toggle_breakpoint, "toggle breakpoint")
map("<leader>dB", function()
    vim.ui.input({ prompt = "Condition: " }, function(condition)
        if condition then dap.set_breakpoint(condition) end
    end)
end, "conditional breakpoint")
map("<leader>de", dapui.eval, "evaluate")
map("<leader>dE", function()
    vim.ui.input({ prompt = "Expression: " }, function(expr)
        if expr then dapui.eval(expr, { enter = true }) end
    end)
end, "evaluate interactive")
