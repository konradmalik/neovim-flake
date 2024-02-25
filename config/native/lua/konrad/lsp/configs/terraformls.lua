-- https://github.com/hashicorp/terraform-ls

local binaries = require("konrad.binaries")
local configs = require("konrad.lsp.configs")

---@type LspConfig
return {
    config = function()
        return {
            name = "terraform-ls",
            cmd = { binaries.terraformls(), "serve" },
            root_dir = configs.root_dir({ ".terraform", ".git" }),
        }
    end,
}
