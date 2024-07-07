-- https://github.com/zigtools/zls
local binaries = require("pde.binaries")

return {
    ---@param bufnr integer
    ---@return vim.lsp.ClientConfig
    config = function(bufnr)
        ---@type vim.lsp.ClientConfig
        return {
            name = "zls",
            cmd = { binaries.zls() },
            root_dir = vim.fs.root(bufnr, { "zls.json", ".git" }),
        }
    end,
}
