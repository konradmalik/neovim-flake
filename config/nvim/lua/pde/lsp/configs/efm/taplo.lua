local binaries = require("pde.binaries")

---@type EfmPlugin
return {
    filetypes = { "toml" },
    entry = {
        formatCommand = { binaries.taplo(), "format", "-" },
        formatStdin = true,
        formatCanRange = true,
    },
}
