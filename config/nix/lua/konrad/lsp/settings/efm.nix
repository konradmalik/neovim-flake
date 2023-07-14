{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/settings/efm.lua" ''
  -- https://github.com/mattn/efm-langserver
  local utils = require('konrad.lsp.settings.efm.utils')
  local efm_config = utils.efm_with({'prettier'})

  return vim.tbl_extend('error', { cmd = { "${pkgs.efm-langserver}/bin/efm-langserver" } }, efm_config)
''
