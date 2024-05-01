local icons = require("pde.icons")
local diag_icons = icons.diagnostics

vim.diagnostic.config({
    virtual_text = {
        prefix = icons.ui.Square,
        source = "if_many",
        spacing = 4,
    },
    update_in_insert = false,
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = diag_icons.Error,
            [vim.diagnostic.severity.WARN] = diag_icons.Warning,
            [vim.diagnostic.severity.HINT] = diag_icons.Hint,
            [vim.diagnostic.severity.INFO] = diag_icons.Information,
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
