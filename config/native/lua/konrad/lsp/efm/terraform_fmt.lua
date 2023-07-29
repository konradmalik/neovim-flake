local efm = require('konrad.lsp.efm')

local fts = { "terraform", "tf", "terraform-vars" }
local entry = {
    formatCommand = "terraform fmt -",
    formatStdin = true,
}

return efm.make_languages_entry_for_fts(fts, entry)
