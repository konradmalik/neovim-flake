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
            -- see: https://github.com/golangci/golangci-lint/issues/1574
            "--fast",
            "'${INPUT}'",
        },
        lintStdin = false,
        lintFormats = { "%.%#:%l:%c %m" },
        rootMarkers = {},
    },
}
