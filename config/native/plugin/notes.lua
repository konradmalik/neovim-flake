local notes_path
if vim.loop.os_uname().sysname == "Darwin" then
    notes_path = "/Users/konrad/Library/Mobile Documents/iCloud~md~obsidian/Documents"
else
    notes_path = "/home/konrad/obsidian"
end
notes_path = notes_path .. "/Personal"

require("konrad.notes").setup({
    base_path = notes_path,
})
