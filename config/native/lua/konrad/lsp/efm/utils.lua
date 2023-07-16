local utils = require("konrad.utils")
local M = {}

---@param fts string[]
---@param entry table
---@return table
M.make_languages_entry_for_fts = function(fts, entry)
    -- efm requires nested tables here (notice brackets in entry)
    local nested = vim.tbl_map(function(t) return { [t] = { entry } } end, fts)
    if #nested < 1 then
        error("must have at least one entry")
    elseif #nested == 1 then
        return nested[1]
    end
    return vim.tbl_extend("error", unpack(nested))
end

---@param plugins string[] names of plugins to add, ex. 'prettier'
M.efm_with = function(plugins)
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

return M
