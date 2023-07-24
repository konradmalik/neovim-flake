-- https://github.com/hrsh7th/vscode-langservers-extracted
local schemastore_ok, schemastore = pcall(require, "schemastore")
if not schemastore_ok then
    vim.notify("cannot load schemastore")
    return
end

local binaries = require('konrad.binaries')
return {
    cmd = { binaries.jsonls, "--stdio" },
    init_options = {
        provideFormatter = false, -- use prettier from null-ls instead
    },
    settings = {
        json = {
            format = false,
            validate = true,
            schemas = schemastore.json.schemas(),
        },
    },
}