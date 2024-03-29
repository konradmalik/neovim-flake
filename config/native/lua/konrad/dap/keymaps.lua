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
map(
    "<leader>dB",
    function() dap.set_breakpoint(vim.ui.input("[DAP] Condition > ")) end,
    "conditional breakpoint"
)

map("<leader>de", dapui.eval, "evaluate")
map(
    "<leader>dE",
    function() dapui.eval(vim.ui.input("[DAP] Expression > ")) end,
    "evaluate interactive"
)
