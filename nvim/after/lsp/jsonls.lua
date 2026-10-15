-- https://github.com/hrsh7th/vscode-langservers-extracted
---@type vim.lsp.Config
return {
    cmd = { "vscode-json-languageserver", "--stdio" },
    ---@type lspconfig.settings.jsonls
    settings = {
        json = {
            validate = {
                enable = true,
            },
            schemas = require("schemastore").json.schemas(),
        },
    },
}
