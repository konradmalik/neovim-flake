-- https://github.com/hrsh7th/vscode-langservers-extracted
local schemastore = require("schemastore")

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
            schemas = schemastore.json.schemas(),
        },
    },
}
