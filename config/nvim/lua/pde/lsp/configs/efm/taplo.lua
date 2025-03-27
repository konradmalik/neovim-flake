---@type EfmPlugin
return {
    filetypes = { "toml" },
    entry = {
        formatCommand = { "taplo", "format", "-" },
        formatStdin = true,
        formatCanRange = true,
    },
}
