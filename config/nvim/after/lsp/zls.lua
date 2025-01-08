-- https://github.com/zigtools/zls
local binaries = require("pde.binaries")

---@type vim.lsp.Config
return {
    cmd = { binaries.zls() },
    filetypes = { "zig", "zir" },
    root_markers = { "zls.json" },
}
