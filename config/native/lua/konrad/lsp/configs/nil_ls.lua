-- https://github.com/oxalica/nil
return {
    config = function()
        local binaries = require("konrad.binaries")
        local configs = require("konrad.lsp.configs")
        return {
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
