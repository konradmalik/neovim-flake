-- https://github.com/oxalica/nil

local binaries = require("pde.binaries")
local configs = require("pde.lsp.configs")

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
            root_dir = configs.root_dir({ "flake.nix", ".git" }),
        }
    end,
}
