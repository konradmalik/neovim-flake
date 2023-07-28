local utils = require('konrad.lsp.efm.utils')
local binaries = require('konrad.binaries')

local fts = { "sh" }
local entry = {
    lintCommand = binaries.shellcheck .. " --color=never --format=gcc -",
    lintStdin = true,
    lintFormats = {
        "-:%l:%c: %trror: %m", "-:%l:%c: %tarning: %m", "-:%l:%c: %tote: %m"
    },
    lintSource = "shellcheck",
}

return utils.make_languages_entry_for_fts(fts, entry)
