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

---@param plugin EfmPlugin
---@return table<string, EfmEntry>
local make_languages_entry_for_plugin = function(plugin)
    local entries = {}
    for _, ft in ipairs(plugin.filetypes) do
        entries[ft] = plugin.entry
    end
    return entries
end

---@param config EfmPlugin
---@return EfmPlugin
local function prepare_plugin(config)
    if type(config.entry.formatCommand) == "table" then
        ---@diagnostic disable-next-line: param-type-mismatch
        config.entry.formatCommand = table.concat(config.entry.formatCommand, " ")
    end
    if type(config.entry.lintCommand) == "table" then
        ---@diagnostic disable-next-line: param-type-mismatch
        config.entry.lintCommand = table.concat(config.entry.lintCommand, " ")
    end
    return config
end

---Build an LspConfig table from the specified EFM plugins
---@param name string unique name of this efm instance
---@param plugins string[] names of plugins to add, ex. 'prettier'
---@return vim.lsp.Config
local function build(name, plugins)
    ---@type table<string, EfmEntry[]>
    local languages = {}
    local allRootMarkers = { [".git/"] = true }
    local formattingEnabled = false
    local rangeFormattingEnabled = false

    for _, v in ipairs(plugins) do
        ---@type EfmPlugin
        local plugin = prepare_plugin(require("pde.lsp.configs.efm." .. v))
        local languages_entry = make_languages_entry_for_plugin(plugin)
        for key, value in pairs(languages_entry) do
            if not languages[key] then languages[key] = {} end
            table.insert(languages[key], value)
        end

        if plugin.entry.rootMarkers then
            for _, marker in ipairs(plugin.entry.rootMarkers) do
                allRootMarkers[marker] = true
            end
        end

        if not formattingEnabled and plugin.entry.formatCommand then formattingEnabled = true end
        if not rangeFormattingEnabled and plugin.entry.formatCanRange then
            rangeFormattingEnabled = true
        end
    end

    local rootMarkers = vim.tbl_keys(allRootMarkers)

    return {
        name = name,
        cmd = { "efm-langserver" },
        init_options = {
            documentFormatting = formattingEnabled,
            documentRangeFormatting = rangeFormattingEnabled,
            hover = false,
            documentSymbol = false,
            codeAction = false,
            completion = false,
        },
        settings = {
            rootMarkers = rootMarkers,
            languages = languages,
        },
    }
end

return {
    ---Build an LspConfig table from the specified EFM plugin
    ---@param plugin string unique name of this efm instance
    ---@return vim.lsp.Config
    config_from_single = function(plugin) return build(plugin, { plugin }) end,

    ---Build an LspConfig table from the specified EFM plugins
    ---@param name string unique name of this efm instance
    ---@param plugins string[] names of plugins to add, ex. 'prettier'
    ---@return vim.lsp.Config
    config_from_multi = function(name, plugins) return build(name, plugins) end,
}
