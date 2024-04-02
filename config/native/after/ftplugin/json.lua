local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("konrad.lsp")

lsp.init(require("konrad.lsp.configs.efm").setup("efmson", { "prettier", "jq" }), bufnr)
lsp.init(require("konrad.lsp.configs.jsonls"), bufnr)
