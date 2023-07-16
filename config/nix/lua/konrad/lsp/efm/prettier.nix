{ pkgs }:
pkgs.writeTextDir "lua/konrad/lsp/efm/prettier.lua" ''
  local utils = require('konrad.lsp.efm.utils')

  local fts = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less",
      "html", "json", "jsonc", "yaml", "markdown", "markdown.mdx", "graphql", "handlebars", "toml" }
  local entry = {
      formatCommand = "${pkgs.nodePackages.prettier}/bin/prettier --plugin-search-dir ${pkgs.nodePackages.prettier-plugin-toml}/lib ''${INPUT}",
      formatStdin = true,
  }
  return utils.make_languages_entry_for_fts(fts, entry)
''
