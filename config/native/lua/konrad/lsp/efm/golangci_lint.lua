local efm = require('konrad.lsp.efm')

local fts = { "go" }
local entry = {
    prefix = "golangci-lint",
    lintCommand = "golangci-lint run --color never --out-format tab ${INPUT}",
    lintStdin = false,
    lintFormats = { '%.%#:%l:%c %m' },
    rootMarkers = {},
}

return efm.make_languages_entry_for_fts(fts, entry)
