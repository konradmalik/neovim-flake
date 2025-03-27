-- https://github.com/zigtools/zls
---@type vim.lsp.Config
return {
    cmd = { "zls" },
    filetypes = { "zig", "zir" },
    root_markers = { "zls.json" },
}
