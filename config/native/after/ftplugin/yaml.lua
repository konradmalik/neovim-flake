local bufnr = vim.api.nvim_get_current_buf()

vim.opt.shiftwidth = 2

local lsp = require("pde.lsp")

lsp.init(require("pde.lsp.configs.efm").setup("prettier", { "prettier" }), bufnr)
lsp.init(require("pde.lsp.configs.yamlls").config(), bufnr)
