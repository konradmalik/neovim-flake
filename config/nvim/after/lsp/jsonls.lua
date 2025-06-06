-- https://github.com/hrsh7th/vscode-langservers-extracted
local schemastore = require("schemastore")

---@type vim.lsp.Config
return {
    cmd = { "vscode-json-languageserver", "--stdio" },
    init_options = {
        provideFormatter = false, -- use prettier instead
    },
    settings = {
        json = {
            format = false,
            validate = true,
            schemas = schemastore.json.schemas(),
        },
    },
}
