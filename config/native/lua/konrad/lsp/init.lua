local M = {}

---@param config table
---@return integer
M.start_and_attach = function(config)
    local made_config = require("konrad.lsp.configs").make_config(config)
    local client_id = vim.lsp.start(made_config)
    if not client_id then
        vim.notify("cannot start lsp: " .. config.cmd, vim.log.levels.ERROR)
        return 0
    end
    vim.lsp.buf_attach_client(vim.api.nvim_get_current_buf(), client_id)
    return client_id
end

return M
