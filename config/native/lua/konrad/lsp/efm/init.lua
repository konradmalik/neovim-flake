-- https://github.com/mattn/efm-langserver
local utils = require('konrad.utils')
local binaries = require('konrad.binaries')
local already_enabled_set = {}
--
---@param plugins string[] names of plugins to add, ex. 'prettier'
function efm_with(plugins)
    local languages = {}
    for _, v in ipairs(plugins) do
        local plugin = require('konrad.lsp.efm.' .. v)
        for key, value in pairs(plugin) do
            if languages[key] then
                languages[key] = utils.concat_lists(languages[key], value)
            else
                languages[key] = value
            end
        end
    end

    return {
        single_file_support = true,
        filetypes = vim.tbl_keys(languages),
        init_options = { documentFormatting = true, },
        settings = {
            rootMarkers = { '.git/' },
            languages = languages,
        },
    }
end

-- an example of changing configuration dynamically, but notice that filetypes that neovim registers the lsp for cannot
-- be changed in that way, just the behavior per filetype
-- local client = vim.lsp.get_active_clients({ name = 'efm' })[1]
-- client.notify('workspace/didChangeConfiguration', {
--     settings = {
--         languages = {
--                lua = {
--                 { formatCommand = "lua-format -i", formatStdin = true },
--             },
--         },
--     },
-- })

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
    local settings = efm_with(all_plugins)
    return vim.tbl_extend('error', { cmd = { binaries.efm } }, settings)
end

return M
