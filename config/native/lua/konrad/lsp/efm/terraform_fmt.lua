local utils = require('konrad.lsp.efm.utils')

local fts = { "terraform", "tf", "terraform-vars" }
local entry = {
    formatCommand = "terraform fmt -",
    formatStdin = true,
}

return utils.make_languages_entry_for_fts(fts, entry)
