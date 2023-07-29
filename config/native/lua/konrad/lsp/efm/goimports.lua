local efm = require('konrad.lsp.efm')

local fts = { "go" }
local entry = {
    formatCommand = "goimports",
    formatStdin = true,
}

return efm.make_languages_entry_for_fts(fts, entry)
