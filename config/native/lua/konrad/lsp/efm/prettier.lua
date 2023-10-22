local binaries = require("konrad.binaries")

return {
    filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "css",
        "scss",
        "less",
        "html",
        "json",
        "jsonc",
        "yaml",
        "markdown",
        "markdown.mdx",
        "graphql",
        "handlebars",
        "toml",
    },
    entry = {
        formatCommand = binaries.prettier()
            .. " --plugin-search-dir "
            .. binaries.prettier_plugin_toml()
            .. " --stdin --stdin-filepath '${INPUT}' ${--range-start:charStart} "
            .. "${--range-end:charEnd} ${--tab-width:tabSize} ${--use-tabs:!insertSpaces}",
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
    },
}
