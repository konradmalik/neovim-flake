-- https://github.com/redhat-developer/yaml-language-server
local binaries = require("pde.binaries")
local schemastore = require("schemastore")

vim.lsp.config("yamlls", {
    cmd = { binaries.yamlls(), "--stdio" },
    filetypes = { "yaml" },
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
            schemas = vim.tbl_extend("error", schemastore.yaml.schemas(), {
                ["kubernetes"] = { "k8s/**/*.yml", "k8s/**/*.yaml" },
                -- or use:
                -- # yaml-language-server: $schema=<urlToTheSchema>
            }),
            schemaStore = {
                -- we use above
                enable = false,
                -- https://github.com/dmitmel/dotfiles/blob/master/nvim/dotfiles/lspconfigs/yaml.lua
                -- yamlls won't work if we disable schemaStore but don't specify url ¯\_(ツ)_/¯
                url = "",
            },
        },
    },
})
