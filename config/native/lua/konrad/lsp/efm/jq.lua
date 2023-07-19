local utils = require('konrad.lsp.efm.utils')
local binaries = require('konrad.binaries')

local fts = { "json" }
local entry = {
    lintCommand = binaries.jq .. " .",
    lintFormats = { "parse %trror: %m at line %l, column %c" },
    lintSource = "jq",
}
return utils.make_languages_entry_for_fts(fts, entry)
