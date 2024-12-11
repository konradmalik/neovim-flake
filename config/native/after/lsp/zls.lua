-- https://github.com/zigtools/zls
local binaries = require("pde.binaries")

vim.lsp.config("zls", {
    cmd = { binaries.zls() },
    filetypes = { "zig", "zir" },
    root_markers = { "zls.json" },
})
