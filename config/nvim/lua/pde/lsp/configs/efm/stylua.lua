-- url: https://github.com/johnnymorganz/stylua
---@type EfmPlugin
return {
    filetypes = { "lua" },
    entry = {
        formatCommand = {
            "stylua",
            "--color",
            "Never",
            "${--range-start:charStart}",
            "${--range-end:charEnd}",
            "--stdin-filepath",
            "'${INPUT}'",
            "-",
        },
        formatCanRange = true,
        formatStdin = true,
        rootMarkers = { "stylua.toml", ".stylua.toml" },
    },
}
