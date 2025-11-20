local cache = {}
local M = {}

---@param name string
---@return string
M.get_and_ensure = function(name)
    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local state = vim.fn.stdpath("state")

    local path = vim.fs.joinpath(state, name)
    if vim.fn.isdirectory(path) == 0 then vim.fn.mkdir(path, "p") end

    return path
end

M.get_notes = function()
    local cached = cache["notes"]
    if cached then return cached end

    local path = M.get_and_ensure("notes")

    cache["notes"] = path
    return path
end

---path to spell file
---@param lang string?, e.g. 'en'
---@return string
M.get_spellfile = function(lang)
    local spellfile_parent = cache["spell"]
    if not spellfile_parent then
        spellfile_parent = M.get_and_ensure("spell")
        cache["spell"] = spellfile_parent
    end
    if not lang then return spellfile_parent end
    return vim.fs.joinpath(spellfile_parent, lang .. ".utf-8.add")
end

return M
