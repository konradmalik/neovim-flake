local function get_cmp_capabilities()
    vim.cmd.packadd({ "cmp-nvim-lsp", bang = true })
    return require("cmp_nvim_lsp").default_capabilities()
end

local M = {}

---@param config vim.lsp.ClientConfig
---@return vim.lsp.ClientConfig
M.merge_capabilities = function(config)
    local nvim = vim.lsp.protocol.make_client_capabilities()
    local cmp = get_cmp_capabilities()

    local default = {
        capabilities = vim.tbl_deep_extend("force", nvim, cmp),
    }

    return vim.tbl_deep_extend("force", default, config)
end

return M
