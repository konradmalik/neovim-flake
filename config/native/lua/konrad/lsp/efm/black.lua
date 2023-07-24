local utils = require('konrad.lsp.efm.utils')

local fts = { "python" }
local entry = {
    formatCommand = "black --no-color --quiet --stdin-filename ${INPUT} -",
    formatStdin = true,
}

return utils.make_languages_entry_for_fts(fts, entry)