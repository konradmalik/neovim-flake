local get_notes_path = function()
    local notes_path
    if vim.uv.os_uname().sysname == "Darwin" then
        notes_path = "/Users/konrad/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    else
        notes_path = "/home/konrad/obsidian"
    end
    notes_path = notes_path .. "/Personal"

    if vim.fn.isdirectory(notes_path) == 0 then
        notes_path = vim.fn.stdpath("state") .. "/notes"
        vim.fn.mkdir(notes_path, "p")
        return notes_path
    end

    return notes_path
end

require("konrad.notes").setup({
    base_path = get_notes_path,
})
