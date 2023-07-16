{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/efm/shfmt.lua" ''
  local utils = require('konrad.lsp.efm.utils')

  local fts = { "sh" }
  local entry = {
    formatCommand = "${pkgs.shfmt}/bin/shfmt",
    formatStdin = true,
  }

  return utils.make_languages_entry_for_fts(fts, entry)
''
