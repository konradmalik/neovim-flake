local M = {}

---@param fts string[]
---@param entry table
---@return table
M.make_languages_entry_for_fts = function(fts, entry)
    -- efm requires nested tables here (notice brackets in entry)
    local nested = vim.tbl_map(function(t) return { [t] = { entry } } end, fts)
    return vim.tbl_extend("error", unpack(nested))
end
---@param plugins string[] names of plugins to add, ex. 'prettier'
M.efm_with = function(plugins)
    local filetypes = {}
    local languages = {}
    for i, v in ipairs(plugins) do
        local plugin = require('konrad.lsp.efm.' .. v)
        filetypes = vim.tbl_extend('keep', vim.tbl_keys(plugin), {})
        languages = vim.tbl_deep_extend('error', plugin, {})
    end

    return {
        single_file_support = true,
        filetypes = filetypes,
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
