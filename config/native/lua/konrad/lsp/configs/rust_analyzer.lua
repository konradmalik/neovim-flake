return {
    config = function()
        local binaries = require("konrad.binaries")
        local configs = require("konrad.lsp.configs")
        return {
            cmd = { binaries.rust_analyzer() },
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
            root_dir = configs.root_dir({ "Cargo.toml", "rust-project.json" }),
        }
    end,
}
