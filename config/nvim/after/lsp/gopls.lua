-- https://github.com/golang/tools/tree/master/gopls
---@type vim.lsp.Config
return {
    cmd = { "gopls" },
    -- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
    settings = {
        gopls = {
            allExperiments = true,
        },
    },
    root_markers = { "go.work", "go.mod" },
    filetypes = { "go", "gomod", "gotmpl", "gowork" },
}
