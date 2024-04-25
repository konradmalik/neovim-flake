local binaries = require("pde.binaries")
---@type EfmPlugin
return {
    filetypes = { "go" },
    entry = {
        prefix = "golangci-lint",
        lintCommand = {
            binaries.golangci_lint(),
            "run",
            "--color",
            "never",
            "--out-format",
            "tab",
            "'${INPUT}'",
        },
        lintStdin = false,
        lintFormats = { "%.%#:%l:%c %m" },
        rootMarkers = {},
    },
}
