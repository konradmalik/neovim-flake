local binaries = require("konrad.binaries")
return {
    filetypes = { "python" },
    entry = {
        formatCommand = {
            binaries.black(),
            "--no-color",
            "--quiet",
            "--stdin-filename",
            "'${INPUT}'",
            "-",
        },
        formatStdin = true,
    },
}
