local M = {}

---@param config table
---@return table
M.make_config = function(config)
    local lspcaps = vim.lsp.protocol.make_client_capabilities()
    local mycaps = require("konrad.lsp.capabilities")
    local base = {
        capabilities = vim.tbl_deep_extend("force", lspcaps, mycaps),
    }

    local result = vim.tbl_deep_extend("force", base, config)

    if type(result.cmd) == "function" then
        result.cmd = result.cmd()
    end

    if type(result.root_dir) == "function" then
        result.root_dir = result.root_dir()
    end

    return result
end

---@param names string[]|string
---@return string|nil
M.root_dir = function(names)
    if type(names) == "string" then
        names = { names }
    end
    local found = vim.fs.find(function(name, path)
        for _, pattern in ipairs(names) do
            if name:match(pattern) then
                return true
            end
        end
        return false
    end, {
        upward = true,
        stop = vim.uv.os_homedir(),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    })
    return vim.fs.dirname(found[1])
end

return M
