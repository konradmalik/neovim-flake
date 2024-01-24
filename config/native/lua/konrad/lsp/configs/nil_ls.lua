-- https://github.com/oxalica/nil

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")
return {
    config = {
        cmd = function() return { binaries.nil_ls() } end,
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
        root_dir = function() return configs.root_dir({ "flake.nix", ".git" }) end,
    },
}
