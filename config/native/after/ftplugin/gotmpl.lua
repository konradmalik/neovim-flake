local bufnr = vim.api.nvim_get_current_buf()

vim.opt.expandtab = false

local lsp = require("konrad.lsp")
lsp.init(require("konrad.lsp.configs.gopls"), bufnr)
