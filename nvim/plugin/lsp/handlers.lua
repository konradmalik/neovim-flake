---@type lsp.Handler
vim.lsp.handlers["workspace/diagnostic/refresh"] = function(_, _, ctx)
    local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
    pcall(vim.diagnostic.reset, ns)
    return true
end
