local bufnr = vim.api.nvim_get_current_buf()

local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.init(efm.build_config("efmson", { "prettier", "jq" }), bufnr)
lsp.init(require("konrad.lsp.configs.jsonls"), bufnr)
