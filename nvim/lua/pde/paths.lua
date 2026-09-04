---@type table<string, string>
local cache = {}

---@class pde.paths
local M = {}

---Path to a directory under stdpath("state"), created if missing.
---@param name string
---@return string
M.get_and_ensure = function(name)
    local cached = cache[name]
    if cached then return cached end

    ---@type string
    ---@diagnostic disable-next-line: assign-type-mismatch
    local state = vim.fn.stdpath("state")

    local path = vim.fs.joinpath(state, name)
    if vim.fn.isdirectory(path) == 0 then vim.fn.mkdir(path, "p") end

    cache[name] = path
    return path
end

M.get_notes = function() return M.get_and_ensure("notes") end

---path to spell file
---@param lang string?, e.g. 'en'
---@return string
M.get_spellfile = function(lang)
    local parent = M.get_and_ensure("spell")
    if not lang then return parent end
    return vim.fs.joinpath(parent, lang .. ".utf-8.add")
end

return M
