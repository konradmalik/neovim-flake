local cache = {}

---@param path string?
---@param subfolder string
---@return string
local function get_or_fallback(path, subfolder)
    local cached = cache[subfolder]
    if cached then return cached end

    ---@diagnostic disable-next-line: cast-local-type
    if not path then path = vim.fn.stdpath("state") end

    path = path .. "/" .. subfolder

    if vim.fn.isdirectory(path) == 0 then vim.fn.mkdir(path, "p") end

    cache[subfolder] = path
    return path
end

return {
    get_notes = function()
        local path = require("pde.system").notes_path
        return get_or_fallback(path, "notes")
    end,

    ---path to spell file
    ---@param lang string?, e.g. 'en'
    ---@return string
    get_spellfile = function(lang)
        local path = require("pde.system").spell_path
        local spellfile_parent = get_or_fallback(path, "spell")
        if not lang then return spellfile_parent end
        return spellfile_parent .. "/" .. lang .. ".utf-8.add"
    end,
}
