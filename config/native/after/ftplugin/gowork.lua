local bufnr = vim.api.nvim_get_current_buf()

vim.opt.expandtab = false

local lsp = require("pde.lsp")
lsp.init(require("pde.lsp.configs.gopls").config(), bufnr)
