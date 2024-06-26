local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.init(require("pde.lsp.configs.efm").setup("efmson", { "prettier", "jq" }), bufnr)
lsp.init(require("pde.lsp.configs.jsonls").config(), bufnr)
