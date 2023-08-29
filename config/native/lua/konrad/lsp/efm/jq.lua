local binaries = require("konrad.binaries")

return {
    filetypes = { "json" },
    entry = {
        lintCommand = binaries.jq .. " .",
        lintFormats = { "parse %trror: %m at line %l, column %c" },
        lintSource = "jq",
    },
}
