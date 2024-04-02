local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("konrad.lsp")

lsp.init(require("konrad.lsp.configs.efm").setup("prettier", { "prettier" }), bufnr)
lsp.init(require("konrad.lsp.configs.ltex_ls"), bufnr)
