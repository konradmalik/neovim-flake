{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/settings/efm/prettier.lua" ''
  local utils = require('konrad.lsp.settings.efm.utils')

  local prettier_fts = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less",
      "html", "json", "jsonc", "yaml", "markdown", "markdown.mdx", "graphql", "handlebars", "toml" }
  local prettier_entry = {
      formatCommand =
      "${pkgs.nodePackages.prettier}/bin/prettier --plugin-search-dir ${pkgs.nodePackages.prettier-plugin-toml}/lib"
  }
  return utils.make_languages_entry_for_fts(prettier_fts, prettier_entry)
''
