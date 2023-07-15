{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/efm/init.lua" ''
  -- https://github.com/mattn/efm-langserver
  local utils = require('konrad.lsp.efm.utils')
  local always_enabled = {'prettier'}

  local M = {}
  -- returns config to be put into lspconfig['efm'].setup(config)
  function M.config_with_plugins(plugins, base_plugins)
      local settings = utils.efm_with(vim.tbl_extend('keep', plugins or {}, base_plugins or always_enabled))
      return vim.tbl_extend('error', { cmd = { "${pkgs.efm-langserver}/bin/efm-langserver" } }, settings)
  end

  return M
''
