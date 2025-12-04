local ms = vim.lsp.protocol.Methods

---@type lsp.Handler
vim.lsp.handlers[ms.workspace_diagnostic_refresh] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    pcall(vim.diagnostic.reset, ns)
    return true
end
