-- https://github.com/hrsh7th/vscode-langservers-extracted

local binaries = require("pde.binaries")
local schemastore = require("schemastore")

vim.lsp.config("jsonls", {
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
    filetypes = { "json", "jsonc" },
})
