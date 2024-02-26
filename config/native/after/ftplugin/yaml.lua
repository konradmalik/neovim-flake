local bufnr = vim.api.nvim_get_current_buf()

vim.opt.shiftwidth = 2

local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.init(efm.build_config("prettier", { "prettier" }), bufnr)
lsp.init(require("konrad.lsp.configs.yamlls"), bufnr)
