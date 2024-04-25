-- https://github.com/hashicorp/terraform-ls

local binaries = require("pde.binaries")
local configs = require("pde.lsp.configs")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = "terraform-ls",
            cmd = { binaries.terraformls(), "serve" },
            root_dir = configs.root_dir({ ".terraform", ".git" }),
        }
    end,
}
