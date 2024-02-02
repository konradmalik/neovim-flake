local fs = require("konrad.fs")

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
    local found = fs.find(names, opts)
    if found then return vim.fs.dirname(found) end
end

return M
