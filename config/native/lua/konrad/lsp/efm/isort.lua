local efm = require('konrad.lsp.efm')

local fts = { "python" }
local entry = {
    formatCommand = "isort --stdout --filename '${INPUT}' -",
    formatStdin = true,
}

return efm.make_languages_entry_for_fts(fts, entry)
