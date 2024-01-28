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

    if type(result.cmd) == "function" then result.cmd = result.cmd() end

    if type(result.root_dir) == "function" then result.root_dir = result.root_dir() end

    return result
end

---@param names string[]|string
---@param opts table? type='file', 'directory' and more
---@return string|nil
M.root_dir = function(names, opts)
    if type(names) == "string" then names = { names } end

    local defaults = {
        upward = true,
        stop = vim.uv.os_homedir(),
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
    }

    opts = vim.tbl_deep_extend("force", defaults, opts or {})

    local found = vim.fs.find(function(name, _)
        for _, pattern in ipairs(names) do
            if name:match(pattern) then return true end
        end
        return false
    end, opts)
    if #found == 0 then return nil end
    return vim.fs.dirname(found[1])
end

return M
