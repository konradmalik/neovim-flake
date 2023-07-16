{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/efm/jq.lua" ''
  local utils = require('konrad.lsp.efm.utils')

  local fts = { "json" }
  local entry = {
    lintCommand = "${pkgs.jq}/bin/jq .",
    lintFormats = {"parse %trror: %m at line %l, column %c"},
    lintSource = "jq",
  }
  return utils.make_languages_entry_for_fts(fts, entry)
''
