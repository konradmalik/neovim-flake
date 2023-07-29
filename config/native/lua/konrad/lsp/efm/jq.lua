local efm = require('konrad.lsp.efm')
local binaries = require('konrad.binaries')

local fts = { "json" }
local entry = {
    lintCommand = binaries.jq .. " .",
    lintFormats = { "parse %trror: %m at line %l, column %c" },
    lintSource = "jq",
}
return efm.make_languages_entry_for_fts(fts, entry)
