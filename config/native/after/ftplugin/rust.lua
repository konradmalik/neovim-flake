local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.start(require("pde.lsp.configs.rust_analyzer").config(bufnr), { bufnr = bufnr })
