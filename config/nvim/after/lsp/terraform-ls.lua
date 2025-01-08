-- https://github.com/hashicorp/terraform-ls
local binaries = require("pde.binaries")

---@type vim.lsp.Config
return {
    cmd = { binaries.terraformls(), "serve" },
    filetypes = { "terraform", "terraform-vars" },
    root_markers = { ".terraform" },
}
