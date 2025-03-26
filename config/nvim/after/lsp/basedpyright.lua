-- https://docs.basedpyright.com/latest/configuration/language-server-settings/

local binaries = require("pde.binaries")

---@type vim.lsp.Config
return {
    cmd = { binaries.basedpyright(), "--stdio" },
    filetypes = { "python" },
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
            },
        },
    },
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
    },
}
