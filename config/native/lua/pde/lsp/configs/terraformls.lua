-- https://github.com/hashicorp/terraform-ls
local binaries = require("pde.binaries")

return {
    ---@param bufnr integer
    ---@return vim.lsp.ClientConfig
    config = function(bufnr)
        ---@type vim.lsp.ClientConfig
        return {
            name = "terraform-ls",
            cmd = { binaries.terraformls(), "serve" },
            root_dir = vim.fs.root(bufnr, { ".terraform", ".git" }),
        }
    end,
}
