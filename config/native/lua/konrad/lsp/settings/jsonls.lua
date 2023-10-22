-- https://github.com/hrsh7th/vscode-langservers-extracted

vim.cmd("packadd SchemaStore.nvim")
local schemastore = require("schemastore")
local binaries = require("konrad.binaries")
return {
    cmd = { binaries.jsonls(), "--stdio" },
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
