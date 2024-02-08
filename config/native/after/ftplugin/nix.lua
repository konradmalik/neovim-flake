vim.opt.shiftwidth = 2

local lsp = require("konrad.lsp")
local lspconfig = require("konrad.lsp.configs.nil_ls").config
lsp.start_and_attach(lspconfig)
