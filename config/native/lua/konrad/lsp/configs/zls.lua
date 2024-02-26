-- https://github.com/zigtools/zls

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

---@type LspConfig
return {
    name = "zls",
    config = function()
        return {
            name = "zls",
            cmd = { binaries.zls() },
            root_dir = configs.root_dir({ "zls.json", ".git" }),
        }
    end,
}
