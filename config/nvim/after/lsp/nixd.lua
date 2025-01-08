-- https://github.com/nix-community/nixd

local binaries = require("pde.binaries")

---@type vim.lsp.Config
return {
    cmd = { binaries.nixd() },
    filetypes = { "nix" },
    settings = {
        nixd = {
            formatting = {
                command = { binaries.nixfmt() },
            },
        },
    },
    root_markers = { "flake.nix" },
}
