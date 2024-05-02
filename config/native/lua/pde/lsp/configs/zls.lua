-- https://github.com/zigtools/zls
local binaries = require("pde.binaries")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = "zls",
            cmd = { binaries.zls() },
            root_dir = vim.fs.root(0, { "zls.json", ".git" }),
        }
    end,
}
