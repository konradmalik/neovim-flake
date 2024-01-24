-- url: https://github.com/johnnymorganz/stylua
local binaries = require("konrad.binaries")
return {
    filetypes = { "lua" },
    entry = {
        formatCanRange = true,
        formatCommand = {
            binaries.stylua(),
            "--color",
            "Never",
            "${--range-start:charStart}",
            "${--range-end:charEnd}",
            "-",
        },
        formatStdin = true,
        rootMarkers = { "stylua.toml", ".stylua.toml" },
    },
}
