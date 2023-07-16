{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/efm/terraform_fmt.lua" ''
  local utils = require('konrad.lsp.efm.utils')

  local fts = { "terraform", "tf", "terraform-vars" }
  local entry = {
    formatCommand = "${pkgs.terraform}/bin/terraform fmt -",
    formatStdin = true,
  }

  return utils.make_languages_entry_for_fts(fts, entry)
''
