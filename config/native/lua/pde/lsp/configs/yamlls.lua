-- https://github.com/redhat-developer/yaml-language-server
local binaries = require("pde.binaries")

vim.cmd.packadd("SchemaStore.nvim")
local schemastore = require("schemastore")
local schemas = vim.tbl_extend("error", schemastore.yaml.schemas(), {
    ["kubernetes"] = { "k8s/**/*.yml", "k8s/**/*.yaml" },
    -- or use:
    -- # yaml-language-server: $schema=<urlToTheSchema>
})

return {
    ---@param bufnr integer
    ---@return vim.lsp.ClientConfig
    config = function(bufnr)
        ---@type vim.lsp.ClientConfig
        return {
            name = "yamlls",
            cmd = { binaries.yamlls(), "--stdio" },
            settings = {
                redhat = {
                    telemetry = {
                        enabled = false,
                    },
                },
                yaml = {
                    format = {
                        enable = false, -- use prettier instead
                    },
                    completion = true,
                    hover = true,
                    validate = true,
                    schemas = schemas,
                    schemaStore = {
                        -- we use above
                        enable = false,
                        -- https://github.com/dmitmel/dotfiles/blob/master/nvim/dotfiles/lspconfigs/yaml.lua
                        -- yamlls won't work if we disable schemaStore but don't specify url ¯\_(ツ)_/¯
                        url = "",
                    },
                },
            },
            root_dir = vim.fs.root(bufnr, ".git"),
        }
    end,
}
