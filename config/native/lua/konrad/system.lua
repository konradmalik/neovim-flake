-- a place for per-system/external config
local notes_path
local spellfile_parent

return {
    repository_name = "neovim-flake",

    get_notes_path = function()
        if not notes_path then
            if vim.uv.os_uname().sysname == "Darwin" then
                notes_path = "/Users/konrad/Library/Mobile Documents/iCloud~md~obsidian/Documents"
            else
                notes_path = "/home/konrad/obsidian"
            end
            notes_path = notes_path .. "/Personal"

            if vim.fn.isdirectory(notes_path) == 0 then
                notes_path = vim.fn.stdpath("state") .. "/notes"
                vim.fn.mkdir(notes_path, "p")
            end
        end

        return notes_path
    end,

    ---path to spell file
    ---@param lang string?, e.g. 'en'
    ---@return string
    spellfile_path = function(lang)
        if not spellfile_parent then
            local repo = vim.uv.os_homedir() .. "/Code/github.com/konradmalik/neovim-flake"
            if vim.fn.isdirectory(repo) == 0 then
                spellfile_parent = vim.fn.stdpath("config") .. "/spell"
            else
                spellfile_parent = repo .. "/files/spell"
            end
        end
        if not lang then return spellfile_parent end
        return spellfile_parent .. "/" .. lang .. ".utf-8.add"
    end,
}
