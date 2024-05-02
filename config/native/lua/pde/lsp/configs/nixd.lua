-- https://github.com/nix-community/nixd

local binaries = require("pde.binaries")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = "nixd",
            cmd = { binaries.nixd() },
            settings = {
                nixd = {
                    formatting = {
                        command = { binaries.nixfmt() },
                    },
                },
            },
            root_dir = vim.fs.root(0, { "flake.nix", ".git" }),
        }
    end,
}
