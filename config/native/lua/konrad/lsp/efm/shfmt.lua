local binaries = require("konrad.binaries")

return {
    filetypes = { "sh" },
    entry = {
        formatCommand = { binaries.shfmt(), "-filename", "'${INPUT}'", "-" },
        formatStdin = true,
    },
}
