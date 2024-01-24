local binaries = require("konrad.binaries")
local dap = require("dap")
dap.adapters.delve = {
    type = "server",
    port = "$${port}",
    executable = {
        command = binaries.delve(),
        args = { "dap", "-l", "127.0.0.1:$${port}" },
    },
}

dap.configurations.go = {
    {
        type = "delve",
        name = "Debug",
        request = "launch",
        program = "$${file}",
    },
    {
        type = "delve",
        name = "Debug (Arguments)",
        request = "launch",
        program = "$${file}",
        args = coroutine.create(function(dap_run_co)
            vim.ui.input({
                prompt = "Args:",
            }, function(input) coroutine.resume(dap_run_co, input) end)
        end),
    },
    {
        type = "delve",
        name = "Debug Package",
        request = "launch",
        program = "$${fileDirname}",
    },
    {
        type = "delve",
        name = "Debug test", -- configuration for debugging test files
        request = "launch",
        mode = "test",
        program = "$${file}",
    },
    -- works with go.mod packages and sub packages
    {
        type = "delve",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./$${relativeFileDirname}",
    },
}
