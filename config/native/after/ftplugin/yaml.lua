local bufnr = vim.api.nvim_get_current_buf()

vim.opt.shiftwidth = 2

local lsp = require("pde.lsp")

lsp.start(
    require("pde.lsp.configs.efm").setup("prettier", { "prettier" }, bufnr),
    { bufnr = bufnr }
)
lsp.start(require("pde.lsp.configs.yamlls").config(bufnr), { bufnr = bufnr })
