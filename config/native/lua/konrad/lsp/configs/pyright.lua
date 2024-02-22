-- https://github.com/microsoft/pyright

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local M = {}

function M.config()
    return {
        name = "pyright",
        cmd = { binaries.pyright(), "--stdio" },
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "openFilesOnly",
                },
            },
        },
        root_dir = configs.root_dir({
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            "pyrightconfig.json",
            ".git",
        }),
    }
end

return M
