local binaries = require("konrad.binaries")

---@type EfmPlugin
return {
    filetypes = { "sh" },
    entry = {
        formatCommand = { binaries.shfmt(), "-filename", "'${INPUT}'", "-" },
        formatStdin = true,
    },
}
