local utils = require('konrad.lsp.efm.utils')

local fts = { "nix" }
local entry = {
    formatCommand = "nixpkgs-fmt",
    formatStdin = true,
}

return utils.make_languages_entry_for_fts(fts, entry)
