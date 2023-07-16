{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/efm/shellcheck.lua" ''
  local utils = require('konrad.lsp.efm.utils')

  local fts = { "sh" }
  local entry = {
    lintCommand = "${pkgs.shellcheck}/bin/shellcheck -f gcc -x -",
    lintStdin = true,
    lintFormats = {
      "%f:%l:%c: %trror: %m", "%f:%l:%c: %tarning: %m", "%f:%l:%c: %tote: %m"
    },
    lintSource = "shellcheck",
  }

  return utils.make_languages_entry_for_fts(fts, entry)
''
