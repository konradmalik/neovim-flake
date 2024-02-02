-- https://github.com/redhat-developer/yaml-language-server
local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local M = {}

function M.config()
    vim.cmd("packadd SchemaStore.nvim")
    local schemastore = require("schemastore")

    return {
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
        root_dir = configs.root_dir(".git"),
    }
end

return M
