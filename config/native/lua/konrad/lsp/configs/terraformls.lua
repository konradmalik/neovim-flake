-- https://github.com/hashicorp/terraform-ls

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

local M = {}

function M.config()
    return {
        cmd = { binaries.terraformls(), "serve" },
        root_dir = configs.root_dir({ ".terraform", ".git" }),
    }
end

return M
