-- https://github.com/redhat-developer/yaml-language-server
---@type vim.lsp.Config
return {
    ---@type lspconfig.settings.yamlls
    settings = {
        redhat = {
            telemetry = {
                enabled = false,
            },
        },
        yaml = {
            schemas = vim.tbl_extend("error", require("schemastore").yaml.schemas(), {
                ["kubernetes"] = { "k8s/**/*.yml", "k8s/**/*.yaml" },
                -- or use:
                -- # yaml-language-server: $schema=<urlToTheSchema>
            }),
            schemaStore = {
                -- we use above
                enable = false,
                -- https://github.com/dmitmel/dotfiles/blob/master/nvim/dotfiles/lspconfigs/yaml.lua
                -- yamlls won't work if we disable schemaStore but don't specify URL ¯\_(ツ)_/¯
                url = "",
            },
        },
    },
}
