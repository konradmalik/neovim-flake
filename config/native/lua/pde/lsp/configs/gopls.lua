-- https://github.com/golang/tools/tree/master/gopls
local binaries = require("pde.binaries")

return {
    ---@param bufnr integer
    ---@return vim.lsp.ClientConfig
    config = function(bufnr)
        ---@type vim.lsp.ClientConfig
        return {
            name = "gopls",
            cmd = { binaries.gopls() },
            -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
            settings = {
                gopls = {
                    allExperiments = true,
                },
            },
            root_dir = vim.fs.root(bufnr, { "go.work", "go.mod", ".git" }),
        }
    end,
}
