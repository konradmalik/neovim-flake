local cache = {}

---@param path string?
---@param subfolder string?
---@return string
local function get_or_fallback(path, subfolder)
    if not path then
        ---@type string
        ---@diagnostic disable-next-line: assign-type-mismatch
        local state = vim.fn.stdpath("state")
        path = state
    end

    if subfolder then path = path .. "/" .. subfolder end

    if vim.fn.isdirectory(path) == 0 then vim.fn.mkdir(path, "p") end

    return path
end

return {
    get_notes = function()
        local cached = cache["notes"]
        if cached then return cached end

        local path = require("pde.system").notes_path
        path = get_or_fallback(path)

        cache["notes"] = path
        return path
    end,

    ---path to spell file
    ---@param lang string?, e.g. 'en'
    ---@return string
    get_spellfile = function(lang)
        local path = require("pde.system").spell_path
        local spellfile_parent = cache["spell"]
        if not spellfile_parent then
            spellfile_parent = get_or_fallback(path, "spell")
            cache["spell"] = spellfile_parent
        end
        if not lang then return spellfile_parent end
        return spellfile_parent .. "/" .. lang .. ".utf-8.add"
    end,
}
