-- https://github.com/oxalica/nil

local binaries = require("konrad.binaries")
return {
    cmd = { binaries.nil_ls() },
    settings = {
        ["nil"] = {
            formatting = {
                command = { binaries.nixpkgs_fmt() },
            },
        },
    },
}
