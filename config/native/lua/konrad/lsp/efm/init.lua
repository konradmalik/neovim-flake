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

local checkFormattingEnabled = function(languages)
    for _, entries in pairs(vim.tbl_values(languages)) do
        for _, entry in ipairs(entries) do
            for key, _ in pairs(entry) do
                if vim.startswith(key, "format") then
                    return true
                end
            end
        end
    end
    return false
end

---@param config table
---@return table
local function prepare_config(config)
    if type(config.entry.formatCommand) == "table" then
        config.entry.formatCommand = table.concat(config.entry.formatCommand, " ")
    end
    if type(config.entry.lintCommand) == "table" then
        config.entry.lintCommand = table.concat(config.entry.lintCommand, " ")
    end
    return config
end

---@param name string unique name of this efm instance
---@param plugins string[] names of plugins to add, ex. 'prettier'
---@return table config to be put into lspconfig['efm'].setup(config)
M.build_config = function(name, plugins)
    local languages = {}
    for _, v in ipairs(plugins) do
        local plugin = require("konrad.lsp.efm." .. v)
        local plugin_config = prepare_config(plugin)
        local languages_entry = make_languages_entry_for_plugin(plugin_config)
        for key, value in pairs(languages_entry) do
            if languages[key] then
                languages[key] = vim.list_extend(languages[key], value)
            else
                languages[key] = value
            end
        end
    end

    local formattingEnabled = checkFormattingEnabled(languages)
    return {
        name = name,
        cmd = { binaries.efm() },
        init_options = {
            documentFormatting = formattingEnabled,
            documentRangeFormatting = formattingEnabled,
        },
        settings = {
            rootMarkers = { ".git/" },
            languages = languages,
        },
    }
end

return M
