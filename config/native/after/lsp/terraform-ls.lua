-- https://github.com/hashicorp/terraform-ls
local binaries = require("pde.binaries")
vim.lsp.config("terraform-ls", {
    cmd = { binaries.terraformls(), "serve" },
    filetypes = { "terraform", "terraform-vars" },
    root_markers = { ".terraform" },
})
