local binaries = require("pde.binaries")
---@type EfmPlugin
return {
    filetypes = { "python" },
    entry = {
        formatCommand = { binaries.isort(), "--stdout", "--filename", "'${INPUT}'", "-" },
        formatStdin = true,
    },
}
