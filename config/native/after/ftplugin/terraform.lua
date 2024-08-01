-- default is empty
vim.opt.commentstring = "// %s"

local bufnr = vim.api.nvim_get_current_buf()

local lsp = require("pde.lsp")

lsp.start(require("pde.lsp.configs.terraformls").config(bufnr), { bufnr = bufnr })

