-- https://github.com/mattn/efm-langserver
local binaries = require('konrad.binaries')
--
---@param plugins string[] names of plugins to add, ex. 'prettier'
local efm_with = function(plugins)
    local languages = {}
    for _, v in ipairs(plugins) do
        local plugin = require('konrad.lsp.efm.' .. v)
        for key, value in pairs(plugin) do
            if languages[key] then
                languages[key] = vim.list_extend(languages[key], value)
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

local M = {}

M.default_plugins = { "prettier", "jq", "shfmt", "shellcheck" }

-- returns config to be put into lspconfig['efm'].setup(config)
M.config_for = function(plugins)
    local settings = efm_with(plugins)
    return vim.tbl_extend('error', { cmd = { binaries.efm } }, settings)
end

return M
