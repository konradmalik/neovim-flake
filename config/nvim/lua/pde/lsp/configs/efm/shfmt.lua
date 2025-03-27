---@type EfmPlugin
return {
    filetypes = { "sh", "bash" },
    entry = {
        formatCommand = { "shfmt", "-filename", "'${INPUT}'", "-" },
        formatStdin = true,
    },
}
