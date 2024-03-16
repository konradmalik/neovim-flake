-- https://github.com/zigtools/zls

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = "zls",
            cmd = { binaries.zls() },
            root_dir = configs.root_dir({ "zls.json", ".git" }),
        }
    end,
}
