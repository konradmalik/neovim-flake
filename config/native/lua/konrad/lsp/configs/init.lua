local M = {}

---@param config table
---@return table
M.make_config = function(config)
    local base = {
        capabilities = require("konrad.lsp.capabilities"),
    }

    return vim.tbl_deep_extend("force", base, config)
end

---@param names string[]|string
---@return string|nil
M.root_dir = function(names)
    local found = vim.fs.find(names, {
        upward = true,
        stop = vim.uv.os_homedir(),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    })
    return vim.fs.dirname(found[1])
end

return M
