local binaries = require("pde.binaries")
---@type EfmPlugin
return {
    filetypes = { "json" },
    entry = {
        lintCommand = { binaries.jq() },
        lintSource = "jq",
        lintStdin = true,
        lintOffset = 1,
        lintFormats = {
            "%m at line %l, column %c",
        },
    },
}
