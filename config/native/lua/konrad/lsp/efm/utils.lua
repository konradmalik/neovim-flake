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

return M
