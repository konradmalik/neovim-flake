-- https://github.com/hrsh7th/vscode-langservers-extracted

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
vim.cmd("packadd SchemaStore.nvim")
local schemastore = require("schemastore")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = "jsonls",
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
            root_dir = configs.root_dir(".git"),
        }
    end,
}
