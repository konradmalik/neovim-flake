local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.init(require("pde.lsp.configs.efm").setup("prettier", { "prettier" }), bufnr)
lsp.init(require("pde.lsp.configs.ltex_ls").config(), bufnr)
