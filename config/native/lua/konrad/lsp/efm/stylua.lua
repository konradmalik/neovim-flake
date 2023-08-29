-- url: https://github.com/johnnymorganz/stylua
local efm = require('konrad.lsp.efm')

local command = 'stylua --color Never ${--range-start:charStart} ${--range-end:charEnd} -'
local fts = { "lua" }
local entry = {
    formatCanRange = true,
    formatCommand = command,
    formatStdin = true,
    rootMarkers = { 'stylua.toml', '.stylua.toml' },
}

return efm.make_languages_entry_for_fts(fts, entry)
