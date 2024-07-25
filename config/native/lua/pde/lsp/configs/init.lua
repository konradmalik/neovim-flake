local M = {}

---@param config vim.lsp.ClientConfig
---@return vim.lsp.ClientConfig
M.make_config = function(config)
    local lspcaps = vim.lsp.protocol.make_client_capabilities()
    local base = {
        capabilities = lspcaps
    }

    return vim.tbl_deep_extend("force", base, config)
end

return M
