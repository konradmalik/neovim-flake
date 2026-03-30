-- https://github.com/hrsh7th/vscode-langservers-extracted
---@type vim.lsp.Config
return {
    cmd = { "vscode-json-languageserver", "--stdio" },
    init_options = {
        provideFormatter = false, -- use prettier instead
    },
    ---@type lspconfig.settings.jsonls
    settings = {
        json = {
            format = {
                enable = false,
            },
            validate = {
                enable = true,
            },
            schemas = require("schemastore").json.schemas(),
        },
    },
}
