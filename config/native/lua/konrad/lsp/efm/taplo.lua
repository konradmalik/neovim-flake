local binaries = require("konrad.binaries")

---@type EfmPlugin
return {
    filetypes = { "toml" },
    entry = {
        formatCommand = { binaries.taplo(), "format", "-" },
        formatStdin = true,
        formatCanRange = true,
    },
}
