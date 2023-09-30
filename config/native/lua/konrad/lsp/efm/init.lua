-- https://github.com/mattn/efm-langserver
local binaries = require("konrad.binaries")

--- @class EfmPlugin
--- @field filetypes string[]
--- @field entry table

---@param plugin EfmPlugin
---@return table
local make_languages_entry_for_plugin = function(plugin)
    -- efm requires nested tables here (notice brackets in entry)
    local nested = vim.tbl_map(function(t)
        return { [t] = { plugin.entry } }
    end, plugin.filetypes)
    if #nested < 1 then
        error("must have at least one entry")
    elseif #nested == 1 then
        return nested[1]
    end
    return vim.tbl_extend("error", unpack(nested))
end

local M = {}

---@param plugins string[] names of plugins to add, ex. 'prettier'
---@return table config to be put into lspconfig['efm'].setup(config)
M.build_lspconfig = function(plugins)
    local languages = {}
    for _, v in ipairs(plugins) do
        local plugin = require("konrad.lsp.efm." .. v)
        local langages_entry = make_languages_entry_for_plugin(plugin)
        for key, value in pairs(langages_entry) do
            if languages[key] then
                languages[key] = vim.list_extend(languages[key], value)
            else
                languages[key] = value
            end
        end
    end

    return {
        cmd = { binaries.efm },
        single_file_support = true,
        filetypes = vim.tbl_keys(languages),
        init_options = {
            documentFormatting = true,
            documentRangeFormatting = true,
        },
        settings = {
            rootMarkers = { ".git/" },
            languages = languages,
        },
    }
end

return M
