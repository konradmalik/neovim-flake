local utils = require('konrad.lsp.efm.utils')
local binaries = require('konrad.binaries')

local fts = { "sh" }
local entry = {
    formatCommand = binaries.shfmt .. '-filename ${INPUT} -',
    formatStdin = true,
}

return utils.make_languages_entry_for_fts(fts, entry)
