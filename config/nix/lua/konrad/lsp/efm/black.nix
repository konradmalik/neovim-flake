{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/efm/black.lua" ''
  local utils = require('konrad.lsp.efm.utils')

  local fts = { "python" }
  local entry = {
    formatCommand = "${pkgs.black}/bin/black --stdin-filename ''${INPUT} --quiet -",
    formatStdin = true,
  }

  return utils.make_languages_entry_for_fts(fts, entry)
''
