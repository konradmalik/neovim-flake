local dap = require("dap")
local pickers = require("pde.dap.pickers")

dap.adapters.coreclr = {
    type = "executable",
    command = "netcoredbg",
    args = { "--interpreter=vscode" },
}

dap.configurations.cs = {
    {
        type = "coreclr",
        name = "Launch netcoredbg",
        request = "launch",
        program = pickers.telescope_select("Path to dll", {
            "fd",
            "--hidden",
            "--no-ignore",
            "--type",
            "f",
            "--full-path",
            "bin/Debug/.+\\.dll",
        }),
    },
    {
        type = "coreclr",
        name = "Launch netcoredbg (with args)",
        request = "launch",
        program = pickers.telescope_select("Path to dll", {
            "fd",
            "--hidden",
            "--no-ignore",
            "--type",
            "f",
            "--full-path",
            "bin/Debug/.+\\.dll",
        }),
        args = function() return vim.fn.input("Args:", "") end,
    },
    {
        type = "coreclr",
        name = "Attach netcoredbg (use VSTEST_HOST_DEBUG=1 for tests)",
        request = "attach",
        processId = require("dap.utils").pick_process,
    },
}
