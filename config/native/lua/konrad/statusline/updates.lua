local M = {}

M.diagnostics = function()
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = vim.api.nvim_create_augroup("StDiagnostics", { clear = true }),
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
        desc = "updates statusline every time diagnostics are updated",
    })
end

M.git = function()
    vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("StGitUpdate", { clear = true }),
        pattern = "GitSignsUpdate",
        callback = vim.schedule_wrap(function() vim.cmd.redrawstatus() end),
        desc = "updates statusline every time git status is updated",
    })
end

return M
