-- url: https://github.com/johnnymorganz/stylua
local binaries = require("pde.binaries")
---@type EfmPlugin
return {
    filetypes = { "lua" },
    entry = {
        formatCommand = {
            binaries.stylua(),
            "--color",
            "Never",
            "${--range-start:charStart}",
            "${--range-end:charEnd}",
            "-",
        },
        formatCanRange = true,
        formatStdin = true,
        rootMarkers = { "stylua.toml", ".stylua.toml" },
    },
}
