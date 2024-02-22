-- https://github.com/zigtools/zls

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local M = {}

function M.config()
    return {
        name = "zls",
        cmd = { binaries.zls() },
        root_dir = configs.root_dir({ "zls.json", ".git" }),
    }
end

return M
