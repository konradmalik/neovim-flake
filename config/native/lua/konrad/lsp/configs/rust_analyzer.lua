local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
return {
    config = {
        cmd = function()
            return { binaries.rust_analyzer() }
        end,
        capabilities = {
            experimental = {
                serverStatusNotification = true,
            },
        },
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
        root_dir = function()
            return configs.root_dir({ "Cargo.toml", "rust-project.json" })
        end,
    },
}
