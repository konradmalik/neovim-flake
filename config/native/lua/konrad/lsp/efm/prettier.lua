local efm = require('konrad.lsp.efm')
local binaries = require('konrad.binaries')

local fts = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less",
    "html", "json", "jsonc", "yaml", "markdown", "markdown.mdx", "graphql", "handlebars", "toml" }

local entry = {
    formatCommand = binaries.prettier .. " --plugin-search-dir " .. binaries.prettier_plugin_toml ..
        ' --stdin --stdin-filepath ${INPUT} ${--range-start:charStart} '
        .. '${--range-end:charEnd} ${--tab-width:tabSize} ${--use-tabs:!insertSpaces}',
    formatStdin = true,
    formatCanRange = true,
    rootMarkers = {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.js",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.json5",
        ".prettierrc.mjs",
        ".prettierrc.cjs",
        ".prettierrc.toml",
    },
}
return efm.make_languages_entry_for_fts(fts, entry)
