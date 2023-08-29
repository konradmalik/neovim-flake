-- url: https://github.com/johnnymorganz/stylua
local command = "stylua --color Never ${--range-start:charStart} ${--range-end:charEnd} -"
return {
    filetypes = { "lua" },
    entry = {
        formatCanRange = true,
        formatCommand = command,
        formatStdin = true,
        rootMarkers = { "stylua.toml", ".stylua.toml" },
    },
}
