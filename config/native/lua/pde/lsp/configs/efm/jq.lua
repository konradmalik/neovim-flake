local binaries = require("pde.binaries")
---@type EfmPlugin
return {
    filetypes = { "json" },
    entry = {
        lintCommand = { binaries.jq(), "." },
        lintFormats = { "parse %trror: %m at line %l, column %c" },
        lintSource = "jq",
    },
}
