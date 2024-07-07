-- https://github.com/hrsh7th/vscode-langservers-extracted

local binaries = require("pde.binaries")
vim.cmd.packadd("SchemaStore.nvim")
local schemastore = require("schemastore")

return {
    ---@param bufnr integer
    ---@return vim.lsp.ClientConfig
    config = function(bufnr)
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
            root_dir = vim.fs.root(bufnr, ".git"),
        }
    end,
}
