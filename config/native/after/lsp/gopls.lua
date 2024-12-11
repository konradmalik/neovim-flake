-- https://github.com/golang/tools/tree/master/gopls
local binaries = require("pde.binaries")

vim.lsp.config("gopls", {
    cmd = { binaries.gopls() },
    -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
    settings = {
        gopls = {
            allExperiments = true,
        },
    },
    root_markers = { "go.work", "go.mod" },
    filetypes = { "go", "gomod", "gotmpl", "gowork" },
})
