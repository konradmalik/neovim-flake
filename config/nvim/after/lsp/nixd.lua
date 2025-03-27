-- https://github.com/nix-community/nixd

---@type vim.lsp.Config
return {
    cmd = { "nixd" },
    filetypes = { "nix" },
    root_markers = { "flake.nix" },
}
