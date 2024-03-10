local fs = require("konrad.fs")

---@class LspConfigBufCommand
---@field cmd function function to execute
---@field opts vim.api.keyset.user_command options

---@class LspConfig
---@field name string unique name
---@field config fun(): vim.lsp.ClientConfig? function to generate the config
---@field buf_commands table<string,LspConfigBufCommand>|nil optional buf commands to be registered on LspAttach

local M = {}

---@param config vim.lsp.ClientConfig
---@return vim.lsp.ClientConfig
M.make_config = function(config)
    local lspcaps = vim.lsp.protocol.make_client_capabilities()
    local mycaps = require("konrad.lsp.capabilities")
    local base = {
        capabilities = vim.tbl_deep_extend("force", mycaps, lspcaps),
    }

    return vim.tbl_deep_extend("force", base, config)
end

---@param names string[]|string
---@param opts table? type='file', 'directory' and more
---@return string|nil
M.root_dir = function(names, opts)
    local found = fs.find(names, opts)
    if found then return vim.fs.dirname(found) end
end

return M
