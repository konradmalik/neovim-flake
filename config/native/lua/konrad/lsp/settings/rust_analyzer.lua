local binaries = require("konrad.binaries")
return {
    cmd = { binaries.rust_analyzer() },
    settings = {
        ["rust-analyzer"] = {
            rustfmt = {
                overrideCommand = binaries.rustfmt(),
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
}
