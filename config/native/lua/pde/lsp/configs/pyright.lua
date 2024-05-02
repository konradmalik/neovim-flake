-- https://github.com/microsoft/pyright

local binaries = require("pde.binaries")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
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
            root_dir = vim.fs.root(0, {
                "pyproject.toml",
                "setup.py",
                "setup.cfg",
                "requirements.txt",
                "Pipfile",
                "pyrightconfig.json",
                ".git",
            }),
        }
    end,
}
