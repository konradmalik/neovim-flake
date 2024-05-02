-- https://github.com/hashicorp/terraform-ls
local binaries = require("pde.binaries")

return {
    config = function()
        ---@type vim.lsp.ClientConfig
        return {
            name = "terraform-ls",
            cmd = { binaries.terraformls(), "serve" },
            root_dir = vim.fs.root(0, { ".terraform", ".git" }),
        }
    end,
}
