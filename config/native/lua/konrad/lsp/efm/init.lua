-- https://github.com/mattn/efm-langserver

---@class EfmEntry
---@field formatCommand? string[]|string
---@field formatStdin? boolean
---@field formatCanRange? boolean
---@field lintCommand? string[]|string
---@field lintStdin? boolean
---@field lintFormats? string[]
---@field lintSource? string
---@field lintIgnoreExitCode? boolean
---@field lintDebounce? string time spec like 2s
---@field lintOffset? integer
---@field hoverCommand? string[]|string
---@field hoverStdin? boolean
---@field lintCategoryMap? { I: string, R: string, C: string, W: string, E: string, F: string }
---@field rootMarkers? string[]

---@class EfmPlugin
---@field filetypes string[]
---@field entry EfmEntry

local binaries = require("konrad.binaries")

---@param plugin EfmPlugin
---@return table
local make_languages_entry_for_plugin = function(plugin)
    -- efm requires nested tables here (notice brackets in entry)
    local nested = vim.tbl_map(function(t) return { [t] = { plugin.entry } } end, plugin.filetypes)
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
                if vim.startswith(key, "format") then return true end
            end
        end
    end
    return false
end

---@param config EfmPlugin
---@return EfmPlugin
local function prepare_config(config)
    if type(config.entry.formatCommand) == "table" then
        config.entry.formatCommand = table.concat(config.entry.formatCommand, " ")
    end
    if type(config.entry.lintCommand) == "table" then
        config.entry.lintCommand = table.concat(config.entry.lintCommand, " ")
    end
    return config
end

---@param list any[]
---@return any[]
local unique_list = function(list)
    local r = {}
    for _, value in ipairs(list) do
        if not r[value] then r[value] = true end
    end
    return vim.tbl_flatten(r)
end

---@param name string unique name of this efm instance
---@param plugins string[] names of plugins to add, ex. 'prettier'
---@return table config to be put into lspconfig['efm'].setup(config)
M.build_config = function(name, plugins)
    local languages = {}
    local allRootMarkers = { ".git/" }
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

        if plugin_config.entry.rootMarkers then
            vim.list_extend(allRootMarkers, plugin_config.entry.rootMarkers)
        end
    end

    local rootMarkers = unique_list(allRootMarkers)

    local formattingEnabled = checkFormattingEnabled(languages)
    return {
        name = name,
        cmd = { binaries.efm() },
        init_options = {
            documentFormatting = formattingEnabled,
            documentRangeFormatting = formattingEnabled,
        },
        settings = {
            rootMarkers = rootMarkers,
            languages = languages,
        },
    }
end

return M
