-- https://github.com/oxalica/nil

local binaries = require("pde.binaries")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = "nil",
            cmd = { binaries.nil_ls() },
            settings = {
                ["nil"] = {
                    formatting = {
                        command = { binaries.nixpkgs_fmt() },
                    },
                    nix = {
                        flake = {
                            autoArchive = true,
                            autoEvalImports = true,
                        },
                    },
                },
            },
            root_dir = vim.fs.root(0, { "flake.nix", ".git" }),
        }
    end,
}
