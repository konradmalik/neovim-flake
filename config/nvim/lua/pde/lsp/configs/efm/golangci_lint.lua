---@type EfmPlugin
return {
    filetypes = { "go" },
    entry = {
        prefix = "golangci-lint",
        lintCommand = {
            "golangci-lint",
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
        rootMarkers = {
            ".golangci.yml",
            ".golangci.yaml",
            ".golangci.toml",
            ".golangci.json",
        },
    },
}
