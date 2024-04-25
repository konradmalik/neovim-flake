-- https://github.com/golang/tools/tree/master/gopls
local binaries = require("pde.binaries")
local configs = require("pde.lsp.configs")

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
            root_dir = configs.root_dir({ "go.work", "go.mod", ".git" }),
        }
    end,
}
