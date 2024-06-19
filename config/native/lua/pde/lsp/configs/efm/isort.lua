local binaries = require("pde.binaries")
---@type EfmPlugin
return {
    filetypes = { "python" },
    entry = {
        formatCommand = { binaries.isort(), "--quiet", "-" },
        formatStdin = true,
    },
}
