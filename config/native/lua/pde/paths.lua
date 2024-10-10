local notes_path
local spellfile_parent

return {
    get_notes = function()
        if not notes_path then
            notes_path = require("pde.system").notes_path
            if not notes_path or vim.fn.isdirectory(notes_path) == 0 then
                notes_path = vim.fn.stdpath("state") .. "/notes"
                vim.fn.mkdir(notes_path, "p")
            end
        end

        return notes_path
    end,

    ---path to spell file
    ---@param lang string?, e.g. 'en'
    ---@return string
    get_spellfile = function(lang)
        if not spellfile_parent then
            local repo = require("pde.system").repository_path
            if not repo or vim.fn.isdirectory(repo) == 0 then
                spellfile_parent = vim.fn.stdpath("config") .. "/spell"
            else
                spellfile_parent = repo .. "/files/spell"
            end
        end
        if not lang then return spellfile_parent end
        return spellfile_parent .. "/" .. lang .. ".utf-8.add"
    end,
}
