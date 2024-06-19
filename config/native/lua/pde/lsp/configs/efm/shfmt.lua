local binaries = require("pde.binaries")

---@type EfmPlugin
return {
    filetypes = { "sh", "bash" },
    entry = {
        formatCommand = { binaries.shfmt(), "-filename", "'${INPUT}'", "-" },
        formatStdin = true,
    },
}
