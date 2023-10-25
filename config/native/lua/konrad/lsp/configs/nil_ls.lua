-- https://github.com/oxalica/nil
local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
return {
    config = function()
        return {
            cmd = { binaries.nil_ls() },
            settings = {
                ["nil"] = {
                    formatting = {
                        command = { binaries.nixpkgs_fmt() },
                    },
                },
            },
            root_dir = configs.root_dir({ "flake.nix", ".git" }),
        }
    end,
}
