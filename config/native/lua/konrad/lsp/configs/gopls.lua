-- https://github.com/golang/tools/tree/master/gopls
local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

---@type LspConfig
return {
    name = "gopls",
    config = function()
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
