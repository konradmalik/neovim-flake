local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local function register_cap()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.experimental = {
        serverStatusNotification = true,
    }
    return capabilities
end

return {
    config = function()
        return {
            cmd = { binaries.rust_analyzer() },
            capabilities = register_cap(),
            settings = {
                ["rust-analyzer"] = {
                    rustfmt = {
                        overrideCommand = { binaries.rustfmt(), "--" },
                    },
                    files = {
                        excludeDirs = {
                            "./.direnv/",
                            "./.git/",
                            "./.github/",
                            "./.gitlab/",
                            "./node_modules/",
                            "./ci/",
                            "./docs/",
                        },
                    },
                    checkOnSave = {
                        enable = true,
                    },
                    diagnostics = {
                        enable = true,
                        experimental = {
                            enable = true,
                        },
                    },
                },
            },
            root_dir = configs.root_dir({ "Cargo.toml", "rust-project.json" }),
        }
    end,
}
