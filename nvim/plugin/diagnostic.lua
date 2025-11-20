vim.diagnostic.config({
    jump = {
        float = true,
    },
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
        numhl = {
            [vim.diagnostic.severity.ERROR] = "DiagnosticError",
            [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
            [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
            [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        },
    },
})

local opts_with_desc = function(desc) return { desc = "[Diagnostic] " .. desc } end

vim.keymap.set(
    "n",
    "<leader>dl",
    vim.diagnostic.setloclist,
    opts_with_desc("Send all from current buffer to location list")
)
vim.keymap.set("n", "<leader>dq", vim.diagnostic.setqflist, opts_with_desc("Send all to QF list"))

vim.api.nvim_create_user_command("DiagnosticsToggle", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    print("Setting diagnostics to: " .. tostring(vim.diagnostic.is_enabled()))
end, {
    desc = "Enable/disable diagnostics globally",
})

local function diagnostic_lines_toggle()
    vim.diagnostic.config({ virtual_lines = not vim.diagnostic.config().virtual_lines })
end

vim.api.nvim_create_user_command("DiagnosticLinesToggle", function()
    diagnostic_lines_toggle()
    print(
        "Setting diagnostic lines (virtual_lines) to: "
            .. tostring(vim.diagnostic.config().virtual_lines)
    )
end, {
    desc = "Enable/disable diagnostics globally",
})

vim.keymap.set(
    "n",
    "<leader>dv",
    diagnostic_lines_toggle,
    opts_with_desc("Toggle diagnostic lines")
)
