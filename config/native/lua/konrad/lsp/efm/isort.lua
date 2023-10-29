local binaries = require("konrad.binaries")
return {
    filetypes = { "python" },
    entry = {
        formatCommand = { binaries.isort(), "--stdout", "--filename", "'${INPUT}'", "-" },
        formatStdin = true,
    },
}
