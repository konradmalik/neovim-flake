local utils = require('konrad.lsp.efm.utils')

local fts = { "go" }
local entry = {
    formatCommand = "goimports",
    formatStdin = true,
}

return utils.make_languages_entry_for_fts(fts, entry)
