local bufnr = vim.api.nvim_get_current_buf()

vim.o.shiftwidth = 2

local lsp = require("pde.lsp")
lsp.start(require("pde.lsp.configs.nixd").config(bufnr), { bufnr = bufnr })
