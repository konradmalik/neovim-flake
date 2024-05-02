-- https://github.com/golang/tools/tree/master/gopls
local binaries = require("pde.binaries")

return {
    config = function()
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
            root_dir = vim.fs.root(0, { "go.work", "go.mod", ".git" }),
        }
    end,
}
