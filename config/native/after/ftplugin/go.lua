local bufnr = vim.api.nvim_get_current_buf()

vim.opt.expandtab = false

local lsp = require("pde.lsp")

lsp.start(require("pde.lsp.configs.gopls").config(bufnr), { bufnr = bufnr })
lsp.start(
    require("pde.lsp.configs.efm").config_from_single("golangci-lint", bufnr),
    { bufnr = bufnr }
)
