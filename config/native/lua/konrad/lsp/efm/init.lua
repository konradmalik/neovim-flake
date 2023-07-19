-- https://github.com/mattn/efm-langserver
local utils = require('konrad.utils')
local efmutils = require('konrad.lsp.efm.utils')
local binaries = require('konrad.binaries')
local already_enabled_set = {}

local M = {}
-- returns config to be put into lspconfig['efm'].setup(config)
-- this is stateful, so calling twice with different plugins will result in the sum of all plugins
function M.updated_config_for(plugins)
    local plugins_set = {}
    for k, v in ipairs(plugins) do
        plugins_set[v] = true
    end

    already_enabled_set = vim.tbl_extend("keep", already_enabled_set, plugins_set or {})
    local all_plugins = vim.tbl_keys(already_enabled_set)
    local settings = efmutils.efm_with(all_plugins)
    return vim.tbl_extend('error', { cmd = { binaries.efm } }, settings)
end

return M
