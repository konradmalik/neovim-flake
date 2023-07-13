# vim: ft=lua
{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/settings/efm.lua" ''
  -- https://github.com/mattn/efm-langserver
  return {
    cmd = { "${pkgs.efm-langserver}/bin/efm-langserver" },
    single_file_support = true,
    filetypes = { 'markdown' },
    init_options = { documentFormatting = true, },
    settings = {
        rootMarkers = { '.git/' },
        languages = {
            markdown = {
                { formatCommand = "${pkgs.nodePackages.prettier}/bin/prettier --plugin-search-dir ${pkgs.nodePackages.prettier-plugin-toml}/lib" },
            },
        },
    },
  }
''
