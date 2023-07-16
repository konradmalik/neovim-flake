{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/efm/nixpkgs_fmt.lua" ''
  local utils = require('konrad.lsp.efm.utils')

  local fts = { "nix" }
  local entry = {
    formatCommand = "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt",
    formatStdin = true,
  }

  return utils.make_languages_entry_for_fts(fts, entry)
''
