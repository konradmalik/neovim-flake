local efm = require('konrad.lsp.efm')
local binaries = require('konrad.binaries')

local fts = { "sh" }
local entry = {
    formatCommand = binaries.shfmt .. '-filename ${INPUT} -',
    formatStdin = true,
}

return efm.make_languages_entry_for_fts(fts, entry)
