local binaries = require("pde.binaries")
---@type EfmPlugin
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
