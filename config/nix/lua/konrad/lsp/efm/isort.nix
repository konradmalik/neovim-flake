{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/efm/isort.lua" ''
  local utils = require('konrad.lsp.efm.utils')

  local fts = { "python" }
  local entry = {
    formatCommand = "${pkgs.isort}/bin/isort --stdout --filename ''${INPUT} -" }
    formatStdin = true,
  }

  return utils.make_languages_entry_for_fts(fts, entry)
''
