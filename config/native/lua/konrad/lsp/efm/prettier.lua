local utils = require('konrad.lsp.efm.utils')
local binaries = require('konrad.binaries')

local fts = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less",
    "html", "json", "jsonc", "yaml", "markdown", "markdown.mdx", "graphql", "handlebars", "toml" }
local entry = {
    formatCommand = binaries.prettier .. " --plugin-search-dir " .. binaries.prettier_plugin_toml .. " ${INPUT}",
    formatStdin = true,
}
return utils.make_languages_entry_for_fts(fts, entry)
