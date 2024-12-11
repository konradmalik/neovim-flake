-- https://github.com/nix-community/nixd

local binaries = require("pde.binaries")

vim.lsp.config("nixd", {
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
})
