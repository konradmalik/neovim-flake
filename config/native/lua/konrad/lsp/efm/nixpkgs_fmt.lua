local efm = require('konrad.lsp.efm')

local fts = { "nix" }
local entry = {
    formatCommand = "nixpkgs-fmt",
    formatStdin = true,
}

return efm.make_languages_entry_for_fts(fts, entry)
