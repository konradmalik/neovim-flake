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

---Build an LspConfig table from the specified EFM plugins
---@param name string unique name of this efm instance
---@param configs string[] a list config names, ex. {'prettier', 'jq'}
---@param languages string[] language (ft) names, ex. {'json','jsonc'}
---@return vim.lsp.Config
local function build(name, configs, languages)
    ---@type table<string, EfmEntry[]>
    local languages_setting = {}
    local allRootMarkers = { [".git/"] = true }
    local formattingEnabled = false
    local rangeFormattingEnabled = false

    for _, config in ipairs(configs) do
        local ok, entry = pcall(require, "efmls-configs.formatters." .. config)
        if not ok then
            ok, entry = pcall(require, "efmls-configs.linters." .. config)
        end
        if not ok then
            vim.notify(
                "no '" .. config .. "' formatter nor linter in efmls-configs",
                vim.log.levels.ERROR
            )
        end

        for _, lang in ipairs(languages) do
            if not languages_setting[lang] then languages_setting[lang] = {} end
            table.insert(languages_setting[lang], entry)
        end

        if entry.rootMarkers then
            for _, marker in ipairs(entry.rootMarkers) do
                allRootMarkers[marker] = true
            end
        end

        if not formattingEnabled and entry.formatCommand then formattingEnabled = true end
        if not rangeFormattingEnabled and entry.formatCanRange then
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
            languages = languages_setting,
        },
        filetypes = vim.tbl_keys(languages_setting),
    }
end

return {
    ---Build an LspConfig table from the specified EFM plugin
    ---@param plugin string config name, ex. "prettier"
    ---@param languages string|string[] language (ft) names
    ---@return vim.lsp.Config
    config_from_single = function(plugin, languages)
        if type(languages) == "string" then languages = { languages } end
        return build(plugin, { plugin }, languages)
    end,

    ---Build an LspConfig table from the specified EFM plugins
    ---@param name string unique name of this efm instance
    ---@param configs string[] a list config names, ex. {'prettier', 'jq'}
    ---@param languages string|string[] language (ft) names, ex. {'json','jsonc'}
    ---@return vim.lsp.Config
    config_from_multi = function(name, configs, languages)
        if type(languages) == "string" then languages = { languages } end
        return build(name, configs, languages)
    end,
}
