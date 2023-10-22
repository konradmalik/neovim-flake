-- url: https://github.com/johnnymorganz/stylua
local binaries = require("konrad.binaries")
local command = binaries.stylua() .. " --color Never ${--range-start:charStart} ${--range-end:charEnd} -"
return {
    filetypes = { "lua" },
    entry = {
        formatCanRange = true,
        formatCommand = command,
        formatStdin = true,
        rootMarkers = { "stylua.toml", ".stylua.toml" },
    },
}
