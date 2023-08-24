local opts_with_desc = function(desc)
    return { noremap = true, silent = true, desc = "[konrad] " .. desc }
end

local open_quicknotes = function()
    local notes_path
    if vim.fn.has('mac') > 0 then
        notes_path = "/Users/konrad/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    else
        notes_path = "/home/konrad/obsidian"
    end
    notes_path = notes_path .. "/Personal/notes.md"

    vim.cmd("botright vsplit + " .. notes_path)
end

vim.keymap.set("n", "<leader>n", open_quicknotes, opts_with_desc("Open quick-notes file"))
