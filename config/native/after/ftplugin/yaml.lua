local bufnr = vim.api.nvim_get_current_buf()

vim.opt.shiftwidth = 2

local efm = require("konrad.lsp.efm")
local lsp = require("konrad.lsp")

lsp.start_and_attach(function() return efm.build_config("prettier", { "prettier" }) end, bufnr)
lsp.init(require("konrad.lsp.configs.yamlls"), bufnr)
