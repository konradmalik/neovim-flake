local bufnr = vim.api.nvim_get_current_buf()

vim.opt.shiftwidth = 2

local lsp = require("konrad.lsp")

lsp.init(require("konrad.lsp.configs.efm").setup("prettier", { "prettier" }), bufnr)
lsp.init(require("konrad.lsp.configs.yamlls"), bufnr)
