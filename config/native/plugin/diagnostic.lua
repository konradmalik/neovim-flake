local icons = require("konrad.icons")

vim.diagnostic.config({
    virtual_text = {
        prefix = icons.ui.Square,
        source = "if_many",
        spacing = 4,
    },
    update_in_insert = false,
    severity_sort = true,
})

local opts_with_desc = function(desc)
    return { noremap = true, silent = true, desc = "[Diagnostic] " .. desc }
end

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts_with_desc("Open in floating window"))
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts_with_desc("Previous"))
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts_with_desc("Next"))
vim.keymap.set('n', '<leader>ll', vim.diagnostic.setloclist,
    opts_with_desc("Send all from current buffer to location list"))
vim.keymap.set('n', '<leader>lq', vim.diagnostic.setqflist, opts_with_desc("Send all to QF list"))

do
    local diagnostics_are_enabled = true;
    vim.api.nvim_create_user_command('DiagnosticsToggle', function()
        if diagnostics_are_enabled then
            vim.diagnostic.disable()
            diagnostics_are_enabled = false
        else
            _, _ = pcall(vim.diagnostic.enable)
            diagnostics_are_enabled = true
        end
        print('Setting diagnostics to: ' .. tostring(diagnostics_are_enabled))
    end, {
        desc = "Enable/disable diagnostics globally",
    })
end
