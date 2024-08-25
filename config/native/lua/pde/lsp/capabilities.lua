local M = {}

---@param config vim.lsp.ClientConfig
---@return vim.lsp.ClientConfig
M.merge_capabilities = function(config)
    local nvim = vim.lsp.protocol.make_client_capabilities()

    local default = {
        capabilities = nvim,
    }

    return vim.tbl_deep_extend("force", default, config)
end

return M
