local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local M = {}

M.config = {
    -- this concrete name is needed by csharpls_extended
    name = "csharp_ls",
    cmd = { binaries.csharp_ls(), "-l", "warning" },
    handlers = {
        ["textDocument/definition"] = require("csharpls-extended-lsp").handler,
    },
    root_dir = function()
        return configs.root_dir(".sln") or configs.root_dir(".csproj") or configs.root_dir(".git")
    end,
}

return M
